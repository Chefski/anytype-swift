import BlocksModels

final class EditorPageAssembly {
    private weak var browser: EditorBrowserController!
    
    init(browser: EditorBrowserController) {
        self.browser = browser
    }
    
    func buildEditorPage(pageId: BlockId) -> EditorPageController {
        return buildEditorModule(pageId: pageId).0
    }
    
    func buildEditorModule(pageId: BlockId) -> (EditorPageController, EditorRouterProtocol) {
        let controller = EditorPageController()
        let document = BaseDocument()
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self
        )
        let attachmentRouter = AttachmentRouter(rootViewController: controller)

        let viewModel = buildViewModel(
            blockId: pageId,
            viewInput: controller,
            document: document,
            router: router,
            attachmentRouter: attachmentRouter
        )
        
        controller.viewModel = viewModel
        
        return (controller, router)
    }
    
    private func buildViewModel(
        blockId: BlockId,
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        attachmentRouter: AttachmentRouterProtocol
    ) -> EditorPageViewModel {
        
        let objectSettinsViewModel = ObjectSettingsViewModel(
            objectId: blockId,
            objectDetailsService: ObjectDetailsService(
                eventHandler: document.eventHandler,
                objectId: blockId
            )
        )
                
        let modelsHolder = ObjectContentViewModelsSharedHolder(objectId: blockId)
        
        let markupChanger = BlockMarkupChanger(
            document: document,
            documentId: blockId
        )
        
        let blockActionHandler = BlockActionHandler(
            documentId: blockId,
            modelsHolder: modelsHolder,
            document: document,
            markupChanger: markupChanger
        )
        
        let eventProcessor = EventProcessor(document: document, modelsHolder: modelsHolder)
        let editorBlockActionHandler = EditorActionHandler(
            document: document,
            blockActionHandler: blockActionHandler,
            eventProcessor: eventProcessor,
            router: router
        )
        
        markupChanger.handler = editorBlockActionHandler
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            document: document
        )
        
        let accessorySwitcher = AccessoryViewSwitcherBuilder()
            .accessoryViewSwitcher(actionHandler: editorBlockActionHandler, router: router)
        let detailsLoader = DetailsLoader(document: document, eventProcessor: eventProcessor)

        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            editorActionHandler: editorBlockActionHandler,
            router: router,
            attachmentRouter: attachmentRouter,
            delegate: blockDelegate,
            accessorySwitcher: accessorySwitcher,
            detailsLoader: detailsLoader
        )
         
        let wholeBlockMarkupViewModel = MarkupViewModel(actionHandler: editorBlockActionHandler)
        
        let headerBuilder = ObjectHeaderBuilder(
            settingsViewModel: objectSettinsViewModel,
            router: router
        )
        
        return EditorPageViewModel(
            documentId: blockId,
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            objectSettinsViewModel: objectSettinsViewModel,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            blockActionHandler: editorBlockActionHandler,
            wholeBlockMarkupViewModel: wholeBlockMarkupViewModel,
            headerBuilder: headerBuilder
        )
    }
}
