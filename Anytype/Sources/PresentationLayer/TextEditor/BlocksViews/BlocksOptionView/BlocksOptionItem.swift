import UIKit

enum BlocksOptionItem: CaseIterable, Comparable {
    case download
    case delete
    case addBlockBelow
    case duplicate
    case turnInto
    case moveTo
    case move
}

extension BlocksOptionItem {
    private typealias BlockOptionImage = UIImage.editor.BlockOption

    var image: UIImage {
        switch self {
        case .delete:
            return BlockOptionImage.delete
        case .addBlockBelow:
            return BlockOptionImage.addBelow
        case .duplicate:
            return BlockOptionImage.duplicate
        case .turnInto:
            return BlockOptionImage.turnInto
        case .moveTo:
            return BlockOptionImage.moveTo
        case .move:
            return BlockOptionImage.move
        case .download:
            return BlockOptionImage.download
        }
    }

    var title: String {
        switch self {
        case .delete:
            return "Delete".localized
        case .addBlockBelow:
            return "Add below".localized
        case .duplicate:
            return "Duplicate".localized
        case .turnInto:
            return "Turn into".localized
        case .moveTo:
            return "Move to".localized
        case .move:
            return "Move".localized
        case .download:
            return "Download".localized
        }
    }
}
