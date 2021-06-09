import BlocksModels

struct BlockBuilder {
    typealias KeyboardAction = BlockTextView.UserAction.KeyboardAction

    static func newBlockId() -> BlockId { "" }

    static func createInformation(block: BlockActiveRecordModelProtocol, action: KeyboardAction, textPayload: String) -> BlockInformation? {
        switch block.content {
        case .text:
            return createContentType(
                block: block,
                action: action,
                textPayload: textPayload
            ).flatMap { (newBlockId(), $0) }
            .map(BlockInformation.init)
        default: return nil
        }
    }

    static func createInformation(block: BlockActiveRecordModelProtocol, action: BlocksViews.Toolbar.UnderlyingAction, textPayload: String = "") -> BlockInformation? {
        switch action {
        case .addBlock:
            return self.createContentType(block: block, action: action, textPayload: textPayload)
                .flatMap { (newBlockId(), $0) }
                .map(BlockInformation.init)
        default: return nil
        }
    }
    
    static func createDefaultInformation() -> BlockInformation {
        return BlockInformation(id: newBlockId(), content: .text(.empty()))
    }

    static func createDefaultInformation(block: BlockActiveRecordModelProtocol) -> BlockInformation? {
        switch block.content {
        case let .text(value):
            switch value.contentType {
            case .toggle: return BlockInformation(id: newBlockId(), content: .text(.empty()))
            default: return nil
            }
        case .smartblock: return BlockInformation(id: newBlockId(), content: .text(.empty()))
        default: return nil
        }
    }

    static func createContentType(block: BlockActiveRecordModelProtocol, action: KeyboardAction, textPayload: String) -> BlockContent? {
        switch block.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.attributedText.string != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.attributedText.string != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.attributedText.string != "": return .text(.init(contentType: .numbered))
            case .toggle where block.isToggled: return .text(.init(contentType: .text))
            case .toggle where blockType.attributedText.string != "": return .text(.init(contentType: .toggle))
            default: return .text(.init(contentType: .text))
            }
        default: return nil
        }
    }

    static func createContentType(block: BlockActiveRecordModelProtocol,
                                  action: BlocksViews.Toolbar.UnderlyingAction,
                                  textPayload: String = "") -> BlockContent? {
        switch action {
        case let .addBlock(blockType):
            switch blockType {
            case let .text(value):
                switch value {
                case .text: return .text(.init(contentType: .text))
                case .h1: return .text(.init(contentType: .header))
                case .h2: return .text(.init(contentType: .header2))
                case .h3: return .text(.init(contentType: .header3))
                case .highlighted: return .text(.init(contentType: .quote))
                }
            case let .list(value):
                switch value {
                case .bulleted: return .text(.init(contentType: .bulleted))
                case .checkbox: return .text(.init(contentType: .checkbox))
                case .numbered: return .text(.init(contentType: .numbered))
                case .toggle: return .text(.init(contentType: .toggle))
                }
            case let .objects(mediaType):
                switch mediaType {
                case .page: return .link(.init(style: .page))
                case .picture: return .file(.init(contentType: .image))
                case .bookmark: return .bookmark(.empty())
                case .file: return .file(.init(contentType: .file))
                case .video: return .file(.init(contentType: .video))
                case .linkToObject: return nil
                }
            case let .other(value):
                switch value {
                case .lineDivider: return .divider(.init(style: .line))
                case .dotsDivider: return .divider(.init(style: .dots))
                case .code: return .text(BlockContent.Text(contentType: .code))
                }
            default: return nil
            }
        default: return nil
        }
    }
}
