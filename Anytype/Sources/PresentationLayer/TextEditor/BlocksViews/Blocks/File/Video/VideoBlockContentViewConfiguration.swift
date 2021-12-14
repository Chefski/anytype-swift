import BlocksModels
import UIKit

struct VideoBlockConfiguration: Hashable {
    
    let file: BlockFile
    var currentConfigurationState: UICellConfigurationState?
    
    init(fileData: BlockFile) {
        self.file = fileData
    }
}

extension VideoBlockConfiguration: BlockConfigurationProtocol {
    
    func makeContentView() -> UIView & UIContentView {
        return VideoBlockContentView(configuration: self)
    }
}