import Combine
import UIKit
import BlocksModels

final class DocumentCoverViewModel {
    
    // MARK: - Private variables
    
    private let cover: DocumentCover
    
    private let fileService = BlockActionsServiceFile()
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlockUserAction, Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var onMediaPickerImageSelect: ((UIImage) -> Void)?
    
    // MARK: - Initializer
    
    init(cover: DocumentCover,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlockUserAction, Never>) {
        self.cover = cover
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentCoverViewModel {
    
    func makeView() -> UIView {
        let view = DocumentCoverView().configured(with: cover)
        view.onCoverTap = { [weak self] in
            self?.showImagePicker()
        }
        
        // TODO: - will be fixed in next PRs
//        onMediaPickerImageSelect = { [weak view] image in
//            view?.showLoader(with: image)
//        }
        
        return view
    }
    
}

private extension DocumentCoverViewModel {
    func showImagePicker() {
        let model = MediaPicker.ViewModel(type: .images)
        model.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else {
                // show error if needed
                return
            }
            
            guard let self = self else { return }
            
            let path = resultInformation.filePath
            
//            DispatchQueue.main.async {
//                self.onMediaPickerImageSelect?(path)
//            }
            
            self.uploadSelectedIconImage(at: path)
        }
        
        userActionSubject.send(
            BlockUserAction.file(.shouldShowImagePicker(model))
        )
    }
    
    func uploadSelectedIconImage(at localPath: String) {
        fileService.uploadFile(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: false
        )
        .flatMap { [weak self] uploadedFileHash in
            self?.detailsActiveModel.update(
                details: [
                    .coverType: DetailsEntry(
                        value: CoverType.uploadedImage
                    ),
                    .coverId: DetailsEntry(
                        value: uploadedFileHash
                    )
                ]
            ) ?? .empty()
        }
        .sinkWithDefaultCompletion("uploading image on \(self)") { _ in }
        .store(in: &self.subscriptions)
    }
    
}
