import Foundation
import BlocksModels

extension URLInputAccessoryView {
    struct Model {
        let blockId: BlockId
        let url: URL?
        let text: NSAttributedString
        let range: NSRange
        
        static let empty = Model(blockId: "", url: nil, text: .init(string: ""), range: .zero)
    }
}

extension URLInputAccessoryView.Model {
    init(data: TextBlockDelegateData, url: URL?) {
        self.init(
            blockId: data.info.id,
            url: url,
            text: data.text.attrString,
            range: data.textView.selectedRange
        )
    }
}
