import UIKit
import FloatingPanel
import BlocksModels
import Amplitude


// MARK: - Cell model

private extension StyleViewController {
    enum Section: Hashable {
        case main
    }

    struct Item: Hashable {
        let kind: BlockText.Style
        let text: String
        let font: UIFont

        private let identifier = UUID()

        static func all(selectedStyle: BlockText.Style) -> [Item] {
            let title: BlockText.Style = selectedStyle == .title ? .title : .header

            return [
                Item(kind: title, text: "Title".localized, font: .title),
                Item(kind: .header2, text: "Heading".localized, font: .heading),
                Item(kind: .header3, text: "Subheading".localized, font: .subheading),
                Item(kind: .text, text: "Text".localized, font: UIFont.bodyRegular)
            ]
        }
    }

    struct ListItem {
        let kind: BlockText.Style
        let icon: UIImage

        static let all: [ListItem] = [
            (BlockText.Style.checkbox, "StyleBottomSheet/checkbox"),
            (BlockText.Style.bulleted, "StyleBottomSheet/bullet"),
            (BlockText.Style.numbered, "StyleBottomSheet/numbered"),
            (BlockText.Style.toggle, "StyleBottomSheet/toggle")
        ]
        .compactMap { (kind, imageName) -> ListItem? in
            guard let image = UIImage(named: imageName) else { return nil }
            return ListItem(kind: kind, icon: image)
        }
    }
}

// MARK: - StyleViewController

final class StyleViewController: UIViewController {
    typealias ActionHandler = (_ action: BlockHandlerActionType) -> Void

    // MARK: - Views

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        styleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        styleCollectionView.backgroundColor = .white
        styleCollectionView.alwaysBounceVertical = false
        styleCollectionView.alwaysBounceHorizontal = true
        styleCollectionView.delegate = self

        return styleCollectionView
    }()

    private var styleDataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private var listStackView: UIStackView = {
        let listStackView = UIStackView()
        listStackView.distribution = .equalCentering
        listStackView.axis = .horizontal
        listStackView.spacing = 7
        listStackView.translatesAutoresizingMaskIntoConstraints = false

        return listStackView
    }()

    private var otherStyleStackView: UIStackView = {
        let otherStyleStackView = UIStackView()
        otherStyleStackView.distribution = .equalCentering
        otherStyleStackView.axis = .horizontal
        otherStyleStackView.spacing = 7
        otherStyleStackView.translatesAutoresizingMaskIntoConstraints = false

        return otherStyleStackView
    }()

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .vertical
        containerStackView.spacing = 16

        return containerStackView
    }()

    // MARK: - Other properties

    private weak var viewControllerForPresenting: UIViewController?
    private var actionHandler: ActionHandler
    private var askColor: () -> UIColor?
    private var askBackgroundColor: () -> UIColor?
    private var didTapMarkupButton: (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void
    private var style: BlockText.Style
    private var restrictions: BlockRestrictions
    // deselect action will be performed on new selection
    private var currentDeselectAction: (() -> Void)?

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter viewControllerForPresenting: view controller where we can present other view controllers
    /// - Parameter actionHandler: Handle bottom sheet  actions, see `StyleViewController.ActionType`
    /// - important: Use weak self inside `ActionHandler`
    init(
        viewControllerForPresenting: UIViewController,
        style: BlockText.Style,
        restrictions: BlockRestrictions,
        askColor: @escaping () -> UIColor?,
        askBackgroundColor: @escaping () -> UIColor?,
        didTapMarkupButton: @escaping (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void,
        actionHandler: @escaping ActionHandler
    ) {
        self.viewControllerForPresenting = viewControllerForPresenting
        self.style = style
        self.askColor = askColor
        self.askBackgroundColor = askBackgroundColor
        self.didTapMarkupButton = didTapMarkupButton
        self.actionHandler = actionHandler
        self.restrictions = restrictions

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.popupStyleMenu)

        setupViews()
        configureStyleDataSource()
    }

    // MARK: - Setup views

    private func setupViews() {
        view.backgroundColor = .white

        containerStackView.addArrangedSubview(listStackView)
        containerStackView.addArrangedSubview(otherStyleStackView)

        view.addSubview(styleCollectionView)
        view.addSubview(containerStackView)

        setupListStackView()
        setupOtherStyleStackView()
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            styleCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            styleCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            styleCollectionView.heightAnchor.constraint(equalToConstant: 48),

            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerStackView.topAnchor.constraint(equalTo: styleCollectionView.bottomAnchor, constant: 24),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
        ])
    }

    private func setupListStackView() {
        let buttonSize = CGSize(width: 75, height: 52)

        ListItem.all.forEach { item in
            let button = ButtonsFactory.roundedBorderуButton(image: item.icon)

            button.layoutUsing.anchors {
                $0.size(buttonSize)
            }

            if item.kind != self.style {
                let isEnabled = restrictions.turnIntoStyles.contains(.text(item.kind))
                button.isEnabled = isEnabled
            }
            listStackView.addArrangedSubview(button)
            setupAction(for: button, with: item.kind)
        }
        listStackView.arrangedSubviews.last?.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }

    private func setupOtherStyleStackView() {
        let buttonSize = CGSize(width: 103, height: 52)
        let smallButtonSize = CGSize(width: 32, height: 32)

        let highlightedButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/highlight"))
        setupAction(for: highlightedButton, with: .quote)

        let calloutButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/callout"))
        setupAction(for: calloutButton, with: .code)

        if .quote != self.style {
            highlightedButton.isEnabled = restrictions.turnIntoStyles.contains(.text(.quote))
        }
        if .code != self.style {
            // TODO: add restrictions when callout block will be introduced
            calloutButton.setImage(UIImage(named: "StyleBottomSheet/calloutInactive"))
            calloutButton.isEnabled = false
        }

        let colorButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/color"))
        colorButton.layer.borderWidth = 0
        colorButton.layer.cornerRadius = smallButtonSize.height / 2
        colorButton.setBackgroundColor(.selected, state: .selected)
        colorButton.addTarget(self, action: #selector(colorActionHandler), for: .touchUpInside)

        let moreButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/more"))
        moreButton.layer.borderWidth = 0
        moreButton.layer.cornerRadius = smallButtonSize.height / 2
        moreButton.setBackgroundColor(.selected, state: .selected)
        
        moreButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            moreButton.isSelected = true

            // show markup view
            self.didTapMarkupButton(self.view) {
                // unselect button on closing markup view
                moreButton.isSelected = false
            }
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)

        let containerForColorAndMoreView = UIView()

        // setup constraints

        highlightedButton.layoutUsing.anchors {
            $0.size(buttonSize)
        }

        calloutButton.layoutUsing.anchors {
            $0.size(buttonSize)
        }

        containerForColorAndMoreView.layoutUsing.stack {
            $0.layoutUsing.anchors {
                $0.center(in: containerForColorAndMoreView)
            }
        } builder: {
            colorButton.layoutUsing.anchors {
                $0.size(smallButtonSize)
            }
            moreButton.layoutUsing.anchors {
                $0.size(smallButtonSize)
            }

            return $0.hStack(
                colorButton,
                $0.hGap(fixed: 14),
                moreButton
            )
        }
        containerForColorAndMoreView.layoutUsing.anchors {
            $0.size(buttonSize)
        }

        otherStyleStackView.addArrangedSubview(highlightedButton)
        otherStyleStackView.addArrangedSubview(calloutButton)
        otherStyleStackView.addArrangedSubview(containerForColorAndMoreView)
    }

    private func setupAction(for button: UIControl, with style: BlockText.Style) {
        let deselectAction = {
            button.isSelected = false
        }

        if style == self.style {
            button.isSelected = true
            currentDeselectAction = deselectAction
        }

        let action =  UIAction(
            handler: { [weak self] _ in
                button.isSelected = true

                self?.selectStyle(style) {
                    button.isSelected = false
                }
                UISelectionFeedbackGenerator().selectionChanged()
            }
        )

        button.addAction(action, for: .touchUpInside)
    }

    // MARK: - configure style collection view

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleCellView, Item> { [weak self] (cell, indexPath, item) in

            if item.kind == self?.style, !cell.isSelected {
                cell.isSelected = true
                self?.styleCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                self?.currentDeselectAction = {  self?.styleCollectionView.deselectItem(at: indexPath, animated: true) }
            }

            var content = StyleCellContentConfiguration()
            content.text = item.text
            content.font = item.font

            if item.kind != self?.style {
                let isDisabled = !(self?.restrictions.turnIntoStyles.contains(.text(item.kind)) ?? false)
                cell.isUserInteractionEnabled = !isDisabled
                content.isDisabled = isDisabled
            }

            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: styleCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.all(selectedStyle: style))
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - action handlers

    private func selectStyle(_ style: BlockText.Style, deselectAction: @escaping () -> Void) {
        guard style != self.style else { return }
        self.style = style

        currentDeselectAction?()
        currentDeselectAction = deselectAction
        if style == .code {
            actionHandler(.toggleWholeBlockMarkup(.keyboard))
        } else {
            actionHandler(.turnInto(style))
        }
    }

    @objc private func colorActionHandler(button: UIControl) {
        guard let viewControllerForPresenting = viewControllerForPresenting else { return }

        button.isSelected = true

        let color = askColor() ?? .textPrimary
        let backgroundColor = askBackgroundColor() ?? .backgroundPrimary

        let contentVC = StyleColorViewController(color: color, backgroundColor: backgroundColor, actionHandler: actionHandler) {
            button.isSelected = false
        }
        viewControllerForPresenting.embedChild(contentVC)

        contentVC.view.pinAllEdges(to: viewControllerForPresenting.view)
        contentVC.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.trailing.equal(to: view.trailingAnchor, constant: -10)
            $0.top.equal(to: view.topAnchor, constant: -8)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - UICollectionViewDelegate

extension StyleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        guard let style = styleDataSource?.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        selectStyle(style.kind) { [weak self] in
            self?.styleCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: - FloatingPanelControllerDelegate

extension StyleViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if fpc.surfaceView.bounds.height / 2 < surfaceOffset {
            return true
        }
        return false
    }
}
