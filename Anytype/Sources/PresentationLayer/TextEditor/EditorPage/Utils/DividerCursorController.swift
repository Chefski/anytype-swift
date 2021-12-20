import UIKit
import Combine
import AnytypeCore

final class DividerCursorController {
    enum MovingMode {
        case none
        case dragNdrop
        case drum
    }

    private enum Constants {
        enum Divider {
            static let cornerRadius = 8.0
            static let origin = CGPoint(x: 8, y: 0)
            static let padding = 8.0
            static let height = 4.0
        }
    }

    var movingMode: MovingMode = .none {
        didSet {
            switch movingMode {
            case .none:
                lastIndexPath = nil
                moveCursorView.removeFromSuperview()
            case .dragNdrop, .drum:
                placeDividerCursor()
            }
        }
    }

    private let collectionView: UICollectionView
    private let view: UIView
    private let movingManager: EditorPageBlocksStateManagerProtocol
    private var cancellables = [AnyCancellable]()
    private var lastIndexPath: IndexPath?

    lazy var moveCursorView: UIView = {
        let view = UIView()
        view.backgroundColor = AnytypeColor.pureAmber.asUIColor
        view.layer.cornerRadius = Constants.Divider.cornerRadius
        view.layer.masksToBounds = true

        view.frame = .init(
            origin: Constants.Divider.origin,
            size: CGSize(width: self.view.bounds.size.width - Constants.Divider.padding * 2, height: Constants.Divider.height)
        )

        return view
    }()

    init(
        movingManager: EditorPageBlocksStateManagerProtocol,
        view: UIView,
        collectionView: UICollectionView
    ) {
        self.movingManager = movingManager
        self.view = view
        self.collectionView = collectionView

        setupSubscription()
    }

    func adjustDivider(at indexPath: IndexPath) {
        let newOrigin: CGFloat

        if let cell = collectionView.cellForItem(at: indexPath) {
            let convertedCellOrigin = view.convert(cell.frame.origin, from: collectionView)
            newOrigin = convertedCellOrigin.y - 2
        } else if let cell = collectionView.cellForItem(
            at: IndexPath(row: indexPath.row - 1, section: indexPath.section)
        ) {
            let convertedCellOrigin = view.convert(cell.frame.origin, from: collectionView)
            newOrigin = cell.frame.height + convertedCellOrigin.y - 2
        } else {
            anytypeAssertionFailure("unexpected case for adjusting divider", domain: .editorPage)
            return
        }

        var previousFrame = moveCursorView.frame

        previousFrame.origin.y = newOrigin
        moveCursorView.frame = previousFrame
        moveCursorView.isHidden = false

        if lastIndexPath != indexPath {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        lastIndexPath = indexPath
    }

    private func setupSubscription() {
        NotificationCenter.Publisher(
            center: .default,
            name: .editorCollectionContentOffsetChangeNotification,
            object: nil
        )
            .compactMap { $0.object as? CGFloat }
            .receiveOnMain()
            .sink { [weak self] in self?.handleScrollUpdate(offset: $0) }
            .store(in: &cancellables)
    }

    private func handleScrollUpdate(offset: CGFloat) {
        switch movingMode {
        case .none:
            return
        case .dragNdrop:
            lastIndexPath.map(adjustDivider(at:))
        case .drum:
            adjustDividerCursorPosition()
        }
    }

    private func placeDividerCursor() {
        guard moveCursorView.superview == nil else {
            anytypeAssertionFailure("Unexpected case", domain: .editorPage)
            return
        }

        view.addSubview(moveCursorView)
        adjustDividerCursorPosition()
    }

    private func adjustDividerCursorPosition() {
        let point = collectionView.convert(view.center, from: view)

        guard let indexPath = collectionView.indexPathForItem(at: point),
              let cell = collectionView.cellForItem(at: indexPath) else {
                  lastIndexPath.map(adjustDivider(at:))
                  return
              }

        let cellPoint = cell.convert(view.center, from: view)
        let cellMidY = cell.bounds.midY
        let isPointAboveMidY = cellPoint.y < cellMidY

        let cellPointPercentage = cellPoint.y / cell.bounds.size.height

        if movingMode == .drum,
           0.33...0.66 ~= cellPointPercentage,
           movingManager.canMoveItemsToObject(at: indexPath) {
            objectSelectionState(at: indexPath)
            return
        }

        collectionView.deselectAllSelectedItems(animated: false)

        var supposedInsertIndexPath = isPointAboveMidY
                                        ? indexPath
                                        : IndexPath(row: indexPath.row + 1, section: indexPath.section)

        if !movingManager.canPlaceDividerAtIndexPath(supposedInsertIndexPath) {
            if let lastIndexPath = lastIndexPath {
                supposedInsertIndexPath = lastIndexPath
            } else {
                return
            }
        }

        adjustDivider(at: supposedInsertIndexPath)
    }

    private func objectSelectionState(at indexPath: IndexPath) {
        moveCursorView.isHidden = true

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }
}
