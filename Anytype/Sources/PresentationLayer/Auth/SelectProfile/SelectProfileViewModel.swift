import SwiftUI
import Combine

@MainActor
final class SelectProfileViewModel: ObservableObject {
    
    @Published var showError: Bool = false
    var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    
    @Published var snackBarData = ToastBarData.empty
    
    private let authService = ServiceLocator.shared.authService()
    private let fileService = ServiceLocator.shared.fileService()
    private let accountEventHandler = ServiceLocator.shared.accountEventHandler()
    
    private var cancellable: AnyCancellable?
    
    private var isAccountRecovering = false
    
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(applicationStateService: ApplicationStateServiceProtocol) {
        self.applicationStateService = applicationStateService
    }
    
    func accountRecover() {
        handleAccountShowEvent()
        
        isAccountRecovering = true
        authService.accountRecover { [weak self] error in
            guard let self = self, let error = error else { return }
            
            self.isAccountRecovering = false
            self.errorText = error.localizedDescription
            self.snackBarData = .empty
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.isAccountRecovering else { return }
            
            self.snackBarData = .init(text: Loc.settingUpEncryptedStoragePleaseWait, showSnackBar: true)
        }
    }
    
}

// MARK: - Private func

private extension SelectProfileViewModel {
    
    func handleAccountShowEvent() {
        cancellable = accountEventHandler.accountShowPublisher
            .sink { [weak self] accountId in
                self?.selectProfile(id: accountId)
            }
    }
    
    func selectProfile(id: String) {
        authService.selectAccount(id: id) { [weak self] status in
            guard let self = self else { return }
            self.isAccountRecovering = false
            self.snackBarData = .empty
            
            switch status {
            case .active:
                self.applicationStateService.state = .home
            case .pendingDeletion:
                self.applicationStateService.state = .delete
            case .deleted:
                self.errorText = Loc.accountDeleted
            case .none:
                self.errorText = Loc.selectAccountError
            }
        }
    }
}
