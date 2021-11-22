import AnytypeCore
import BlocksModels

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    private let blocksContainer: BlockContainerModelProtocol
    private let detailsStorage: ObjectDetailsStorageProtocol
    
    init(blocksContainer: BlockContainerModelProtocol, detailsStorage: ObjectDetailsStorageProtocol) {
        self.blocksContainer = blocksContainer
        self.detailsStorage = detailsStorage
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId)  -> NSAttributedString? {
        guard let info = blocksContainer.model(id: blockId)?.information else { return nil }
        guard case let .text(blockText) = info.content else { return nil }
        
        let range = blockText.anytypeText(using: detailsStorage).attrString.wholeRange
        
        return toggleMarkup(markup, blockId: blockId, range: range)
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        guard let (model, content) = blockData(blockId: blockId) else { return nil }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return nil }

        let attributedText = content.anytypeText(using: detailsStorage).attrString
        let shouldApplyMarkup = !attributedText.hasMarkup(markup, range: range)

        return apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    func setMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        return updateMarkup(markup, shouldApplyMarkup: true, blockId: blockId, range: range)
    }

    func removeMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        return updateMarkup(markup, shouldApplyMarkup: false, blockId: blockId, range: range)
    }

    private func updateMarkup(
        _ markup: MarkupType, shouldApplyMarkup: Bool, blockId: BlockId, range: NSRange
    ) -> NSAttributedString? {
        guard let (model, content) = blockData(blockId: blockId) else { return nil }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return nil }

        let attributedText = content.anytypeText(using: detailsStorage).attrString

        return apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    
    private func apply(
        _ action: MarkupType,
        shouldApplyMarkup: Bool,
        block: BlockModelProtocol,
        content: BlockText,
        attributedText: NSAttributedString,
        range: NSRange
    ) -> NSAttributedString? {
        // Ignore changing markup in empty string
        guard range.length != 0 else { return nil }
        
        let modifier = MarkStyleModifier(
            attributedString: attributedText,
            anytypeFont: content.contentType.uiFont
        )
        
        modifier.apply(action, shouldApplyMarkup: shouldApplyMarkup, range: range)
        return NSAttributedString(attributedString: modifier.attributedString)
    }
    
    private func blockData(blockId: BlockId) -> (BlockModelProtocol, BlockText)? {
        guard let model = blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("Can't find block with id: \(blockId)", domain: .blockMarkupChanger)
            return nil
        }
        guard case let .text(content) = model.information.content else {
            anytypeAssertionFailure("Unexpected block type \(model.information.content)", domain: .blockMarkupChanger)
            return nil
        }
        return (model, content)
    }
}
