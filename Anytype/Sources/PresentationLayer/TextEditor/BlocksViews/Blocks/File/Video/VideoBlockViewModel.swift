import BlocksModels
import UIKit

struct VideoBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation
    let fileData: BlockFile
    
    let showVideoPicker: (BlockId) -> ()
    let downloadVideo: (FileId) -> ()
    
    func didSelectRowInTableView() {
        switch fileData.state {
        case .empty, .error:
            showVideoPicker(blockId)
        case .uploading, .done:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(state: .default)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .done:
            return VideoBlockConfiguration(fileData: fileData)
        }
    }
    
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.video,
            text: "Upload a video".localized,
            state: state
        )
    }
}