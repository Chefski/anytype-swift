
public enum BlockContentType: Hashable {
    case smartblock(BlockSmartblock.Style)
    case text(BlockText.Style)
    case file(FileContentType)
    case divider(BlockDivider.Style)
    case bookmark(BlockBookmark.Style)
    case link(BlockLink.Style)
    case layout(BlockLayout.Style)
    case featuredRelations

    public var style: String {
        switch self {
        case let .smartblock(style):
            return String(describing: style)
        case let .text(style):
            return String(describing: style)
        case let .file(style):
            return String(describing: style)
        case let .divider(style):
            return String(describing: style)
        case let .bookmark(style):
            return String(describing: style)
        case let .link(style):
            return String(describing: style)
        case let .layout(style):
            return String(describing: style)
        case .featuredRelations:
            return "featuredRelations"
        }
    }
}
