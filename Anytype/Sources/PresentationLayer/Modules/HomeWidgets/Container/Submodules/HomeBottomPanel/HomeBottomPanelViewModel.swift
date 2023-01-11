import Foundation
import BlocksModels

@MainActor
final class HomeBottomPanelViewModel: ObservableObject {
    
    struct Button: Hashable {
        let image: ObjectIconImage
        @EquatableNoop var onTap: () -> Void
    }
    
    // MARK: - Private properties
    
    private let toastPresenter: ToastPresenterProtocol
    private let accountManager: AccountManager
    private let subscriptionService: SubscriptionsServiceProtocol
    private let subscriotionBuilder: HomeBottomPanelSubscriptionDataBuilderProtocol
    private var subscriptionData: [ObjectDetails] = []
    
    // MARK: - Public properties
    
    @Published var buttons: [Button] = []
    
    init(
        toastPresenter: ToastPresenterProtocol,
        accountManager: AccountManager,
        subscriptionService: SubscriptionsServiceProtocol,
        subscriotionBuilder: HomeBottomPanelSubscriptionDataBuilderProtocol
    ) {
        self.toastPresenter = toastPresenter
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.subscriotionBuilder = subscriotionBuilder
        updateModels()
        setupSubscription()
    }
        
    // MARK: - Private
    
    private func updateModels() {
        buttons = [
            HomeBottomPanelViewModel.Button(image: .imageAsset(.Widget.search), onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap search")
            }),
            HomeBottomPanelViewModel.Button(image: .imageAsset(.Widget.add), onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap create object")
            }),
            HomeBottomPanelViewModel.Button(image: subscriptionData.first?.objectIconImage ?? .placeholder(nil), onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap space")
           })
        ]
    }
    
    private func setupSubscription() {
        let data = subscriotionBuilder.build(objectId: accountManager.account.info.accountSpaceId)
        subscriptionService.startSubscription(data: data, update: { [weak self] in self?.handleEvent(update: $1) })
    }
    
    private func handleEvent(update: SubscriptionUpdate) {
        subscriptionData.applySubscriptionUpdate(update)
        updateModels()
    }
}
