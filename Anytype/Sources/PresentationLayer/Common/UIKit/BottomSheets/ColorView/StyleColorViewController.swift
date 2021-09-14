import UIKit


private enum SectionKind: Int, CaseIterable {
    case textColor
    case backgroundColor
}

extension StyleColorViewController {
    enum ColorItem: Hashable {
        case text(BlockColor)
        case background(BlockBackgroundColor)

        var color: UIColor {
            switch self {
            case .background(let color):
                return color.color
            case .text(let color):
                return color.color
            }
        }

        static let text = BlockColor.allCases.map { ColorItem.text($0) }
        static let background = BlockBackgroundColor.allCases.map { ColorItem.background($0) }
    }
}

final class StyleColorViewController: UIViewController {
    typealias ActionHandler = (_ action: BlockHandlerActionType) -> Void

    // MARK: - Viwes

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let items = sectionIndex == 0 ? ColorItem.text : ColorItem.background

            var groups: [NSCollectionLayoutItem] = []
            let itemDimension: CGSize = .init(width: 36.0, height: 34.0)

            // max count items in row
            let maxItemsInRow = Int(layoutEnvironment.container.contentSize.width / itemDimension.width)

            // calc last row items count
            let lastRowItemsCount = items.count % maxItemsInRow

            // add group for all items except last if lastRowItemsCount != 0
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemDimension.width), heightDimension: .absolute(itemDimension.height))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemDimension.height))
            let itemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            // remain space in row after placing possible max count items
            let remainSpaceInRow: CGFloat = layoutEnvironment.container.contentSize.width - (CGFloat(maxItemsInRow) * itemDimension.width)
            // space for leading and trailing edge
            let edgeSpacing: CGFloat = remainSpaceInRow / 2
            itemsGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: edgeSpacing, bottom: 0, trailing: edgeSpacing)

            groups.append(itemsGroup)

            // add group for last row where items need to be centered
            if lastRowItemsCount != 0 {
                let lastRowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemDimension.height))
                let lastRowItemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: lastRowGroupSize, subitems: [item])
                // left space in row
                let leftSpaceInRow: CGFloat = layoutEnvironment.container.contentSize.width - (CGFloat(lastRowItemsCount) * itemDimension.width)
                // space for leading and trailing edge
                let lastRowEdgeSpacing: CGFloat = leftSpaceInRow / 2
                lastRowItemsGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: lastRowEdgeSpacing, bottom: 0, trailing: lastRowEdgeSpacing)

                groups.append(lastRowItemsGroup)
            }

            // main group - include itemsGroup and lastRowItemsGroup
            let mainGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
            let mainGroup = NSCollectionLayoutGroup.vertical(layoutSize: mainGroupSize, subitems: groups)

            let section = NSCollectionLayoutSection(group: mainGroup)

            if sectionIndex == 0 {
                section.contentInsets = .init(top: 0, leading: 0, bottom: 7, trailing: 0)
            }

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        styleCollectionView.backgroundColor = .white
        styleCollectionView.isScrollEnabled = false
        styleCollectionView.delegate = self
        styleCollectionView.allowsMultipleSelection = true

        return styleCollectionView
    }()

    private let backdropView = UIView()
    let containerView = UIView()

    // MARK: - Properties

    private var styleDataSource: UICollectionViewDiffableDataSource<SectionKind, ColorItem>?
    private var color: UIColor?
    private var backgroundColor: UIColor?
    private var actionHandler: ActionHandler
    private var viewDidCloseHandler: () -> Void

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter color: Foreground color
    /// - Parameter backgroundColor: Background color
    init(color: UIColor? = .grayscale90,
         backgroundColor: UIColor? = .grayscaleWhite,
         actionHandler: @escaping ActionHandler,
         viewDidClose: @escaping () -> Void) {
        self.actionHandler = actionHandler
        self.viewDidCloseHandler = viewDidClose
        self.color = color
        self.backgroundColor = backgroundColor

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureStyleDataSource()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12.0
        containerView.layer.cornerCurve = .continuous

        containerView.layer.shadowColor = UIColor.grayscale90.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowRadius = 40

        view.backgroundColor = .clear
        backdropView.backgroundColor = .clear
        let tapGeastureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backdropViewTapped))
        backdropView.addGestureRecognizer(tapGeastureRecognizer)

        view.addSubview(backdropView)
        view.addSubview(containerView)
        containerView.addSubview(styleCollectionView)

        setupLayout()
    }

    private func setupLayout() {
        backdropView.pinAllEdges(to: view)

        styleCollectionView.layoutUsing.anchors {
            $0.top.equal(to: containerView.topAnchor, constant: 15)
            $0.leading.equal(to: containerView.leadingAnchor, constant: 9)
            $0.trailing.equal(to: containerView.trailingAnchor, constant: -9)
            $0.bottom.equal(to: containerView.bottomAnchor)
        }
    }

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleColorCellView, ColorItem> { (cell, indexPath, item) in
            let content = StyleColorCellContentConfiguration(colorItem: item)
            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<SectionKind, ColorItem>(collectionView: styleCollectionView) {
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, identifier: ColorItem) -> UICollectionViewCell? in

            var color = self?.color
            if indexPath.section != 0 {
                color = self?.backgroundColor
            }

            if identifier.color == color {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        updateSnapshot()
    }

    private func updateSnapshot(with colorItems: [ColorItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ColorItem>()
        snapshot.appendSections([.textColor, .backgroundColor])
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ColorItem>()
        snapshot.appendSections([.textColor, .backgroundColor])
        snapshot.appendItems(ColorItem.text, toSection: .textColor)
        snapshot.appendItems(ColorItem.background, toSection: .backgroundColor)
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }

    @objc private func backdropViewTapped() {
        removeFromParentEmbed()
        viewDidCloseHandler()
    }
}

// MARK: - UICollectionViewDelegate

extension StyleColorViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard !(collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false) else { return false }
        guard let colorItem = styleDataSource?.itemIdentifier(for: indexPath) else {
            return false
        }
        let indexPathToDeselect = collectionView.indexPathsForSelectedItems?.filter { $0.section == indexPath.section }
        indexPathToDeselect?.forEach { collectionView.deselectItem(at: $0, animated: false) }
        
        switch colorItem {
        case .text(let color):
            self.color = color.color
            actionHandler(.setTextColor(color))
        case .background(let color):
            self.backgroundColor = color.color
            actionHandler(.setBackgroundColor(color))
        }
        
        return true
    }
}
