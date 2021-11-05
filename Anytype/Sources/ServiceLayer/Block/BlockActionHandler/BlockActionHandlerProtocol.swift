import Foundation
import BlocksModels

protocol BlockActionHandlerProtocol: AnyObject {

    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    @discardableResult
    func turnIntoPage(blockId: BlockId) -> BlockId?
    
    func setTextColor(_ color: BlockColor, blockId: BlockId)
    func setBackgroundColor(_ color: BlockBackgroundColor, blockId: BlockId)
    func duplicate(blockId: BlockId)
    func setFields(_ fields: [BlockFields], blockId: BlockId)
    func fetch(url: URL, blockId: BlockId)
    func checkbox(selected: Bool, blockId: BlockId)
    func toggle(blockId: BlockId)
    func setAlignment(_ alignment: LayoutAlignment, blockId: BlockId)
    func delete(blockId: BlockId)
    func moveTo(targetId: BlockId, blockId: BlockId)
    func createEmptyBlock(parentId: BlockId?)
    func setLink(url: URL?, range: NSRange, blockId: BlockId)
    func setLinkToObject(linkBlockId: BlockId, range: NSRange, blockId: BlockId)
    
    func toggleWholeBlockMarkup(_ markup: TextAttributesType, blockId: BlockId)

    func upload(blockId: BlockId, filePath: String)
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId?
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func changeCaretPosition(range: NSRange)
    func changeText(_ text: NSAttributedString, info: BlockInformation)
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation)
    func changeTextStyle(_ attribute: TextAttributesType, range: NSRange, blockId: BlockId)
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId)
    func uploadFileAt(localPath: String, blockId: BlockId)
}
