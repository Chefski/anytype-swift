import Foundation
import Combine
import BlocksModels
import UIKit
import FloatingPanel
import SwiftUI

final class ObjectSettingsViewModel: ObservableObject, Dismissible {
    var onDismiss: () -> Void = {} {
        didSet {
            objectActionsViewModel.dismissSheet = onDismiss
        }
    }
    
    var settings: [ObjectSetting] {
        settingsBuilder.build(
            details: details,
            restrictions: objectActionsViewModel.objectRestrictions,
            isLocked: document.isLocked
        )
    }
    
    var details: ObjectDetails {
        document.details ?? .empty
    }
    
    let objectActionsViewModel: ObjectActionsViewModel

    let relationsViewModel: RelationsListViewModel
    
    private(set) var popupLayout: AnytypePopupLayoutType = .constantHeight(height: 0, floatingPanelStyle: false)
    
    private weak var popup: AnytypePopupProxy?
    private weak var router: EditorRouterProtocol?
    private let document: BaseDocumentProtocol
    private let objectDetailsService: DetailsServiceProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    
    private var subscription: AnyCancellable?
    
    init(
        document: BaseDocumentProtocol,
        objectDetailsService: DetailsServiceProtocol,
        router: EditorRouterProtocol
    ) {
        self.document = document
        self.objectDetailsService = objectDetailsService
        self.router = router

        self.relationsViewModel = RelationsListViewModel(
            router: router,
            relationsService: RelationsService(objectId: document.objectId),
            isObjectLocked: document.isLocked
        )

        self.objectActionsViewModel = ObjectActionsViewModel(
            objectId: document.objectId,
            popScreenAction: { [weak router] in
                router?.goBack()
            }
        )
        
        setupSubscription()
        onDocumentUpdate()
    }

    func showLayoutSettings() {
        router?.showLayoutPicker()
    }
    
    func showIconPicker() {
        router?.showIconPicker()
    }
    
    func showCoverPicker() {
        router?.showCoverPicker()
    }
    
    func viewDidUpdateHeight(_ height: CGFloat) {
        popupLayout = .constantHeight(height: height, floatingPanelStyle: true)
        popup?.updateLayout(false)
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] _ in
            self?.onDocumentUpdate()
        }
    }
    
    private func onDocumentUpdate() {
        objectWillChange.send()
        if let details = document.details {
            objectActionsViewModel.details = details
            relationsViewModel.update(with: document.parsedRelations, isObjectLocked: document.isLocked)
        }
        objectActionsViewModel.isLocked = document.isLocked
        objectActionsViewModel.objectRestrictions = document.objectRestrictions
    }
}

extension ObjectSettingsViewModel: AnytypePopupViewModelProtocol {
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: ObjectSettingsView(viewModel: self))
    }
    
}
