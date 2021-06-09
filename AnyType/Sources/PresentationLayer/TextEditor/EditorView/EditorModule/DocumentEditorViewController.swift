import BlocksModels
import UIKit
import Combine
import FloatingPanel


final class DocumentEditorViewController: UIViewController {

    private enum Constants {
        static let headerReuseId = "header"
        static let cellIndentationWidth: CGFloat = 24
        static let cellReuseId: String = NSStringFromClass(UICollectionViewListCell.self)
    }

    private var dataSource: UICollectionViewDiffableDataSource<DocumentSection, BaseBlockViewModel>?
    private let viewModel: DocumentEditorViewModel
    
    private let collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.backgroundColor = .white
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(frame: UIScreen.main.bounds,
                                               collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private var insetsHelper: ScrollViewContentInsetsHelper?
    
    private var subscriptions: Set<AnyCancellable> = []
    // Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = .init()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    init(viewModel: DocumentEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.setNavigationItem(windowHolder?.rootNavigationController.navigationBar.topItem)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        insetsHelper = nil
        guard isMovingFromParent else { return }
        self.viewModel.applyPendingChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        insetsHelper = ScrollViewContentInsetsHelper(scrollView: collectionView)
    }

    private func setupUI() {
        setupCollectionView()
        setupCollectionViewDataSource()
        setupInteractions()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.pinAllEdges(to: view)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    private func setupCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BaseBlockViewModel> { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }

        let codeCellRegistration = UICollectionView.CellRegistration<CodeBlockCellView, BaseBlockViewModel> { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }

        let dataSource = UICollectionViewDiffableDataSource<DocumentSection, BaseBlockViewModel>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: BaseBlockViewModel) -> UICollectionViewCell? in
            if item is CodeBlockViewModel {
                return collectionView.dequeueConfiguredReusableCell(using: codeCellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <DocumentDetailsView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (detailsView, string, indexPath) in
            guard let viewModel = self?.viewModel.detailsViewModel else { return }

            detailsView.configure(model: viewModel)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: $2)
        }
        
        self.dataSource = dataSource
    }

    private func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BaseBlockViewModel) {
        cell.contentConfiguration = item.buildContentConfiguration()
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel()
        cell.contentView.isUserInteractionEnabled = !self.viewModel.selectionEnabled()

        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
    }

    private func setupInteractions() {
        self.configured()
        
        listViewTapGestureRecognizer.addTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
        self.view.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    @objc private func tapOnListViewGestureRecognizerHandler() {
        guard viewModel.selectionEnabled() == false else {
            return
        }
        
        let location = self.listViewTapGestureRecognizer.location(in: listViewTapGestureRecognizer.view)
        guard collectionView.visibleCells.first(where: {$0.frame.contains(location)}).isNil else {
            return
        }
        
        viewModel.handlingTapOnEmptySpot()
    }

    /// Add handlers to viewModel state changes
    private func configured() {
        self.viewModel.publicSizeDidChangePublisher.receiveOnMain().sink { [weak self] (value) in
            self?.updateView()
        }.store(in: &self.subscriptions)

        self.viewModel.updateElementsPublisher.sink { [weak self] value in
            self?.handleUpdateBlocks(blockIds: value)
        }.store(in: &self.subscriptions)

        self.viewModel.selectionHandler.selectionEventPublisher().sink(receiveValue: { [weak self] value in
            self?.handleSelection(event: value)
        }).store(in: &self.subscriptions)
    }
    
    private func handleSelection(event: EditorSelectionIncomingEvent) {
        switch event {
        case .selectionDisabled:
            deselectAllBlocks()
        case let .selectionEnabled(event):
            switch event {
            case .isEmpty:
                deselectAllBlocks()
            case let .nonEmpty(count, _):
                // We always count with this "1" because of top title block, which is not selectable
                if count == collectionView.numberOfItems(inSection: 0) - 1 {
                    collectionView.selectAllItems(startingFrom: 1)
                }
            }
            collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = false }
        }
    }
        
    private func deselectAllBlocks() {
        self.collectionView.deselectAllSelectedItems()
        self.collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = true }
    }
}

// MARK: - Initial Update data

extension DocumentEditorViewController {
    private func updateView() {
        UIView.performWithoutAnimation {
            dataSource?.refresh(animatingDifferences: true)
        }
    }

    private func handleUpdateBlocks(blockIds: Set<BlockId>) {
        guard let dataSource = dataSource else { return }

        let sectionSnapshot = dataSource.snapshot(for: .first)
        var snapshot = dataSource.snapshot()
        var itemsForUpdate = sectionSnapshot.visibleItems.filter { blockIds.contains($0.blockId) }

        let focusedViewModelIndex = itemsForUpdate.firstIndex(where: { viewModel -> Bool in
            guard let indexPath = dataSource.indexPath(for: viewModel) else { return false }
            return collectionView.cellForItem(at: indexPath)?.isAnySubviewFirstResponder() ?? false
        })
        if let index = focusedViewModelIndex {
            updateFocusedViewModel(blockViewModel: itemsForUpdate.remove(at: index))
        }

        if itemsForUpdate.isEmpty {
            return
        }
        snapshot.reloadItems(itemsForUpdate)
        apply(snapshot)
    }

    private func updateFocusedViewModel(blockViewModel: BaseBlockViewModel) {
        guard let indexPath = dataSource?.indexPath(for: blockViewModel) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }

        let textModel = blockViewModel as? TextBlockViewModel
        cell.indentationLevel = blockViewModel.indentationLevel()
        cell.contentConfiguration = blockViewModel.buildContentConfiguration()
        let prefferedSize = cell.systemLayoutSizeFitting(CGSize(width: cell.frame.size.width,
                                                                height: UIView.layoutFittingCompressedSize.height))
        if cell.frame.size.height != prefferedSize.height {
            updateView()
        }
        if let focusAt = viewModel.document.userSession?.focusAt() {
            textModel?.set(focus: focusAt)
        }
    }
        
    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>,
                       completion: (() -> Void)? = nil) {
        let selectedCells = collectionView.indexPathsForSelectedItems

        UIView.performWithoutAnimation {
            self.dataSource?.apply(snapshot, animatingDifferences: true) { [weak self] in
                self?.updateVisibleNumberedItems()

                completion?()

                selectedCells?.forEach {
                    self?.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
                }
            }
        }
    }
    
    private func applySnapshotAndSetFocus(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>) {
        apply(snapshot) { [weak self] in
            self?.focusOnFocusedBlock()
        }
    }

    // TODO: It should not be here. Move it to TextBlockViewModel
    private func updateVisibleNumberedItems() {
        self.collectionView.indexPathsForVisibleItems.forEach {
            guard let builder = self.viewModel.blocksViewModels[safe: $0.row] else { return }
            let content = builder.block.content
            guard case let .text(text) = content, text.contentType == .numbered else { return }
            self.collectionView.cellForItem(at: $0)?.contentConfiguration = builder.buildContentConfiguration()
        }
    }

    private func focusOnFocusedBlock() {
        let userSession = viewModel.document.userSession
        // TODO: we should move this logic to TextBlockViewModel
        if let id = userSession?.firstResponderId(), let focusedAt = userSession?.focusAt(),
           let blockViewModel = viewModel.blocksViewModels.first(where: { $0.blockId == id }) as? TextBlockViewModel {
                blockViewModel.set(focus: focusedAt)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DocumentEditorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
        if self.viewModel.selectionEnabled() {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if !self.viewModel.selectionEnabled() {
            return
        }
        self.viewModel.didSelectBlock(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let viewModel = dataSource?.itemIdentifier(for: indexPath) else { return false }
        if self.viewModel.selectionEnabled() {
            if case let .text(text) = viewModel.block.content {
                return text.contentType != .title
            }
            return true
        }
        switch viewModel.block.content {
        case .text:
            return false
        case let .file(file) where [.done, .uploading].contains(file.state):
            return false
        default:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard let blockViewModel = dataSource?.itemIdentifier(for: indexPath) else { return nil }
        return blockViewModel.contextMenuInteraction()
    }
}

// MARK: TODO: Remove later.
extension DocumentEditorViewController {
    func getViewModel() -> DocumentEditorViewModel { self.viewModel }
}

// MARK: - EditorModuleDocumentViewInput

extension DocumentEditorViewController: EditorModuleDocumentViewInput {

    func reloadFirstSection() {
        // Workaround: Supplementary view reloaded only on reloadSections
        // That couse dismiss keyboard if keyboard is open and you update details on desktop
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.reloadSections([.first])
        apply(snapshot)
    }
    
    func updateData(_ rows: [BaseBlockViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>()
        snapshot.appendSections([.first])
        snapshot.appendItems(rows)
        applySnapshotAndSetFocus(snapshot)
    }

    func showCodeLanguageView(with languages: [String], completion: @escaping (String) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        modalPresentationStyle = .pageSheet
        present(searchListViewController, animated: true)
    }

    func showStyleMenu(blockModel: BlockModelProtocol, blockViewModel: BaseBlockViewModel) {
        guard let viewControllerForPresenting = parent else { return }
        self.view.endEditing(true)

        BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: viewControllerForPresenting,
            delegate: self,
            blockModel: blockModel
        ) { [weak self] action in
            self?.viewModel.handleAction(action)
        }

        if let indexPath = dataSource?.indexPath(for: blockViewModel) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
    }
}

extension DocumentEditorViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        collectionView.deselectAllSelectedItems()
        
        guard let snapshot = self.dataSource?.snapshot() else { return }

        let userSession = viewModel.document.userSession
        let blockModel = userSession?.firstResponder()

        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)

        let blockViewModel = itemIdentifiers.first { blockViewModel in
            blockViewModel.blockId == blockModel?.information.id
        }

        if let blockViewModel = blockViewModel as? TextBlockViewModel {
            let focus = userSession?.focusAt() ?? .end
            blockViewModel.set(focus: focus)
        }
    }
}
