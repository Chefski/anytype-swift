import UIKit
import BlocksModels
import AnytypeCore

struct AccessoryViewBuilder {
    static func accessoryState(
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        pasteboardService: PasteboardServiceProtocol,
        document: BaseDocumentProtocol,
        onShowStyleMenu: @escaping RoutingAction<BlockInformation>,
        onBlockSelection: @escaping RoutingAction<BlockInformation>,
        pageService: PageServiceProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    ) -> AccessoryViewStateManager {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let cursorModeAccessoryViewModel = CursorModeAccessoryViewModel(
            handler: actionHandler,
            onShowStyleMenu: onShowStyleMenu,
            onBlockSelection: onBlockSelection
        )
        
        let markupViewModel = MarkupAccessoryViewModel(
            document: document,
            actionHandler: actionHandler,
            pageService: pageService,
            linkToObjectCoordinator: linkToObjectCoordinator
        )

        let changeTypeViewModel = ChangeTypeAccessoryViewModel(
            router: router,
            handler: actionHandler,
            searchService: SearchService(),
            objectService: ServiceLocator.shared.objectActionsService(),
            document: document
        ) { [weak router, weak actionHandler] in
            router?.showTypes(
                selectedObjectId: document.details?.type,
                onSelect: { id in
                    actionHandler?.setObjectTypeUrl(id)
                }
            )
        }

        let typeListViewModel = HorizonalTypeListViewModel(itemProvider: changeTypeViewModel)

        let horizontalTypeListView = HorizonalTypeListView(viewModel: typeListViewModel)

        let changeTypeView = ChangeTypeAccessoryView(
            viewModel: changeTypeViewModel,
            changeTypeView: horizontalTypeListView.asUIView()
        )

        let cursorModeAccessoryView = CursorModeAccessoryView(viewModel: cursorModeAccessoryViewModel)
        let markupModeAccessoryView = MarkupAccessoryView(viewModel: markupViewModel)

        let slashMenuViewModel = SlashMenuViewModel(
            handler: SlashMenuActionHandler(
                actionHandler: actionHandler,
                router: router,
                pasteboardService: pasteboardService
            )
        )
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            viewModel: slashMenuViewModel
        )

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            cursorModeAccessoryView: cursorModeAccessoryView,
            markupAccessoryView: markupModeAccessoryView,
            changeTypeView: changeTypeView,
            document: document
        )

        accessoryViewSwitcher.onDoneButton = {
            guard let typeURL = document.details?.objectType else { return }

            router.showTemplatesAvailabilityPopupIfNeeded(
                document: document,
                templatesTypeURL: .dynamic(typeURL.url)
            )
        }

        slashMenuViewModel.resetSlashMenuHandler = { [weak accessoryViewSwitcher] in
            accessoryViewSwitcher?.restoreDefaultState()

        }

        // set delegate
        let stateManager = AccessoryViewStateManagerImpl(switcher: accessoryViewSwitcher, handler: actionHandler)
        mentionsView.delegate = stateManager
        cursorModeAccessoryView.setDelegate(stateManager)

        return stateManager
    }
    
    private static let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
