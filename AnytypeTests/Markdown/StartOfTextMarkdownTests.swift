import XCTest
@testable import Anytype
@testable import BlocksModels

class StartOfTextMarkdownTests: XCTestCase {

    var listener: MarkdownListenerImpl!
    
    override func setUpWithError() throws {
        listener = MarkdownListenerImpl()
    }

    func testStartOfTextMarkdowns() throws {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                testEnteringSpaceAfterTextMarkdown(shortcut: text, style: shortcut.style)
            }
        }
    }
    
    private func testEnteringSpaceAfterTextMarkdown(
        shortcut: String,
        style: BlockText.Style,
        success: Bool = true
    ) {
        let shortcutByDeletingSpaces = shortcut.replacingOccurrences(of: " ", with: "")
        let data = buildData(
            text: shortcutByDeletingSpaces,
            carretPosition: shortcutByDeletingSpaces.count
        )

        let markdownChange = listener.markdownChange(
            textView: data.textView,
            replacementText: " ",
            range: data.textView.selectedRange
        )

        if success {
            switch markdownChange {
            case .setText:
                break // Not implemented. It is about inline markups
            case let .turnInto(newStyle, text: newText):
                XCTAssertEqual(newStyle, style)
                XCTAssertEqual(newText.string, "")
            default:
                XCTFail("Wrong case")
            }
        } else {
           XCTAssertNil(markdownChange)
        }
        
    }

    private func buildData(text: String, carretPosition: Int) -> TextBlockDelegateData {
        let textView = UITextView()
        textView.text = text
        textView.selectedRange = NSRange(location: carretPosition, length: 0)
        
        let block = BlockModelMock(information: .emptyText)
        let text = UIKitAnytypeText(text: text, style: .body)
        
        return TextBlockDelegateData(textView: textView, block: block, text: text)
    }
}
