import Foundation


public enum BlockContent: Hashable, CustomStringConvertible {
    case smartblock(BlockSmartblock)
    case text(BlockText)
    case file(BlockFile)
    case divider(BlockDivider)
    case bookmark(BlockBookmark)
    case link(BlockLink)
    case layout(BlockLayout)
    case featuredRelations
    case dataView(BlockDataview)
    case unsupported
    
    public var type: BlockContentType {
        switch self {
        case let .smartblock(smartblock):
            return .smartblock(smartblock.style)
        case let .text(text):
            return .text(text.contentType)
        case let .file(file):
            return .file(file.contentType)
        case let .divider(divider):
            return .divider(divider.style)
        case let .bookmark(bookmark):
            return .bookmark(bookmark.type)
        case let .link(link):
            return .link(link.style)
        case let .layout(layout):
            return .layout(layout.style)
        case .featuredRelations:
            return .featuredRelations
        case .dataView:
            return .dataView
        case .unsupported:
            return .text(.text)
        }
    }

    public var description: String {
        switch self {
        case .smartblock:
            return "smartblock"
        case .text:
            return "text"
        case .file:
            return "file"
        case .divider:
            return "divider"
        case .bookmark:
            return "bookmark"
        case .link:
            return "link"
        case .layout:
            return "layout"
        case .featuredRelations:
            return "featuredRelations"
        case .dataView:
            return "dataView"
        case .unsupported:
            return "unknown"
        }
    }
}

public extension BlockContent {
    var isText: Bool {
        if case .text = self {
            return true
        }
        
        return false
    }

    var isEmpty: Bool {
        switch self {
        case .text(let blockText):
            return blockText.text.isEmpty
        default:
            return false
        }
    }
}
