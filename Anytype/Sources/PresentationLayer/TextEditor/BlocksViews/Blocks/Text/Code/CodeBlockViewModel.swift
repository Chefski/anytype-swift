import Combine
import UIKit
import BlocksModels

struct CodeBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?
    
    var hashable: AnyHashable {
        [
            information,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let block: BlockModelProtocol
    var information: BlockInformation { block.information }
    var indentationLevel: Int { block.indentationLevel }
    let content: BlockText
    let detailsStorage: ObjectDetailsStorageProtocol
    private var codeLanguage: CodeLanguage {
        CodeLanguage.create(
            middleware: block.information.fields[FieldName.codeLanguage]?.stringValue
        )
    }

    let becomeFirstResponder: (BlockModelProtocol) -> ()
    let textDidChange: (BlockModelProtocol, UITextView) -> ()
    let showCodeSelection: (BlockModelProtocol) -> ()

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return CodeBlockContentConfiguration(
            content: content,
            backgroundColor: block.information.backgroundColor,
            codeLanguage: codeLanguage,
            detailsStorage: detailsStorage,
            becomeFirstResponder: {
                self.becomeFirstResponder(self.block)
            },
            textDidChange: { textView in
                self.textDidChange(self.block, textView)
            },
            showCodeSelection: {
                self.showCodeSelection(self.block)
            }
        )
    }
    
    func didSelectRowInTableView() { }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)\ntext: \(content.anytypeText(using: detailsStorage).attrString.string.prefix(10))...\ntype: \(block.information.content.type.style.description)"
    }
}
