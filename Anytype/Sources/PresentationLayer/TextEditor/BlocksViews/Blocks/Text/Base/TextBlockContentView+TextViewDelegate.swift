import AnytypeCore
import UIKit
import BlocksModels

extension TextBlockContentView: CustomTextViewDelegate {    
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange) {
        switch change {
        case .become:
            blockDelegate.becomeFirstResponder(blockId: currentConfiguration.information.id)
        case .resign:
            blockDelegate.resignFirstResponder(blockId: currentConfiguration.information.id)
        }
    }
    
    func willBeginEditing() {
        blockDelegate.willBeginEditing(data: delegateData)
    }

    func didBeginEditing() {
        blockDelegate.didBeginEditing()
    }
    
    func didEndEditing() {
        blockDelegate.didEndEditing()
    }
    
    func changeText(text: NSAttributedString) {
        handler.changeText(text, info: currentConfiguration.information)
        blockDelegate.textDidChange()
    }
    
    func changeTextStyle(text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange) {
        handler.changeTextStyle(
            text: text, attribute: attribute, range: range, blockId: currentConfiguration.information.id
        )
    }
    
    func changeLink(text: NSAttributedString, range: NSRange) {
        currentConfiguration.changeLink(text, range)
    }
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction) -> Bool {
        switch action {
        case .enterInsideContent,
             .enterAtTheEndOfContent,
             .enterAtTheBeginingOfContent:
            // In the case of frequent pressing of enter
            // we can send multiple split requests to middle
            // from the same block, it will leads to wrong order of blocks in array,
            // adding a delay makes impossible to press enter very often
            if currentConfiguration.pressingEnterTimeChecker.exceedsTimeInterval() {
                handler.handleKeyboardAction(action, info: currentConfiguration.information)
            }
            return false
        case .deleteOnEmptyContent, .deleteAtTheBeginingOfContent:
            handler.handleKeyboardAction(action, info: currentConfiguration.information)
            return true
        }
    }
    
    func showPage(blockId: BlockId) {
        guard let details = currentConfiguration.detailsStorage.get(id: blockId) else {
            // Deleted objects goes here
            return
        }
        
        if !details.isArchived && !details.isDeleted {
            currentConfiguration.showPage(blockId)
        }
    }
    
    func openURL(_ url: URL) {
        currentConfiguration.openURL(url)
    }
    
    func changeCaretPosition(_ range: NSRange) {
        handler.changeCaretPosition(range: range)
    }
    
    func shouldChangeText(range: NSRange, replacementText: String, mentionsHolder: Mentionable) -> Bool {
        let changeType = textView.textView.textChangeType(changeTextRange: range, replacementText: replacementText)
        blockDelegate.textWillChange(changeType: changeType)
        
        let shouldChangeText = !mentionsHolder.removeMentionIfNeeded(text: replacementText)
        if !shouldChangeText {
            handler.changeText(textView.textView.attributedText, info: currentConfiguration.information)
        }
        return shouldChangeText
    }
    
    // MARK: - Private
    private var blockDelegate: BlockDelegate {
        currentConfiguration.blockDelegate
    }
    
    private var handler: BlockActionHandlerProtocol {
        currentConfiguration.actionHandler
    }
    
    private var delegateData: TextBlockDelegateData {
        TextBlockDelegateData(
            textView: textView.textView,
            block: currentConfiguration.block,
            text: currentConfiguration.content.anytypeText(using: currentConfiguration.detailsStorage)
        )
    }
}
