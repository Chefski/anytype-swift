import Combine
import UIKit
import BlocksModels

final class DocumentIconViewModel {
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    
    private var onMediaPickerImageSelect: ((String) -> Void)?
    
    private let documentIcon: DocumentIcon?
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    init(documentIcon: DocumentIcon?,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.documentIcon = documentIcon
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentIconViewModel {
    
    func makeView() -> UIView? {
        switch documentIcon {
        case let .emoji(iconEmoji):
            return makeIconEmojiView(with: iconEmoji)
        case let .imageId(imageId):
            return makeIconImageView(with: imageId)
        case .none:
            return nil
        }
    }
    
}

// MARK: - Private extension

private extension DocumentIconViewModel {
    
    func makeIconEmojiView(with emoji: IconEmoji) -> UIView {
        let view = DocumentIconEmojiView().configured(with: emoji)
        view.enableMenuInteraction { [weak self] userAction in
            self?.handleIconUserAction(userAction)
        }
        
        return view
    }
    
    func makeIconImageView(with imageId: String) -> UIView {
        let view = DocumentIconImageView().configured(with: .default(imageId: imageId))
        view.enableMenuInteraction { [weak self] userAction in
            self?.handleIconUserAction(userAction)
        }
        
        onMediaPickerImageSelect = { imagePath in
            DispatchQueue.main.async {
                view.configure(model: .imageUploading(imagePath: imagePath))
            }
        }
        
        return view
    }
    
}

// MARK: - Actions handler

private extension DocumentIconViewModel {
    
    // Sorry 🙏🏽
    typealias BlockUserAction = BlocksViews.UserAction
    
    func handleIconUserAction(_ action: DocumentIconViewUserAction) {
        switch action {
        case .select:
            showEmojiPicker()
        case .random:
            setRandomEmoji()
        case .upload:
            showImagePicker()
        case .remove:
            removeIcon()
        }
    }
    
    func showEmojiPicker() {
        let model = EmojiPicker.ViewModel()
        
        model.$selectedEmoji
            .safelyUnwrapOptionals()
            .sink { [weak self] emoji in
                self?.updateDetails(
                    [
                        DetailsContent.iconEmoji(
                            Details.Information.Content.Emoji(value: emoji.unicode)
                        ),
                        DetailsContent.iconImage(
                            Details.Information.Content.ImageId(value: "")
                        )
                    ]
                )
            }
            .store(in: &subscriptions)
        
        userActionSubject.send(
            BlockUserAction.specific(
                BlockUserAction.SpecificAction.page(
                    BlockUserAction.Page.UserAction.emoji(
                        BlockUserAction.Page.UserAction.EmojiAction.shouldShowEmojiPicker(model)
                    )
                )
            )
        )
    }
    
    func showImagePicker() {
        let model = MediaPicker.ViewModel(type: .images)
        model.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else {
                // show error if needed
                return
            }
            
            guard let self = self else { return }
            
            let localPath = resultInformation.filePath
            
            self.onMediaPickerImageSelect?(localPath)
            self.uploadSelectedIconImage(at: localPath)
        }
        
        userActionSubject.send(
            BlockUserAction.specific(
                BlockUserAction.SpecificAction.file(
                    BlockUserAction.File.FileAction.shouldShowImagePicker(
                        .init(model: model)
                    )
                )
            )
        )
    }
    
    func uploadSelectedIconImage(at localPath: String) {
        fileService.uploadFile.action(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: false
        )
        .flatMap { [weak self] uploadedFile in
            self?.detailsActiveModel.update(
                details: [
                    DetailsContent.iconEmoji(
                        Details.Information.Content.Emoji(value: "")
                    ),
                    DetailsContent.iconImage(
                        Details.Information.Content.ImageId(value: uploadedFile.hash)
                    )
                ]
            ) ?? .empty()
        }
        .sink(
            receiveCompletion: { value in
                switch value {
                case .finished: break
                case let .failure(value):
                    assertionFailure("uploading image error \(value) on \(self)")
                }
            }
        ) { _ in }
        .store(in: &self.subscriptions)
    }
    
    func setRandomEmoji() {
        let emoji = EmojiPicker.Manager().random()
        
        updateDetails(
            [
                DetailsContent.iconEmoji(
                    Details.Information.Content.Emoji(value: emoji.unicode)
                ),
                DetailsContent.iconImage(
                    Details.Information.Content.ImageId(value: "")
                )
            ]
        )
    }
    
    func removeIcon() {
        updateDetails(
            [
                DetailsContent.iconEmoji(
                    Details.Information.Content.Emoji(value: "")
                ),
                DetailsContent.iconImage(
                    Details.Information.Content.ImageId(value: "")
                )
            ]
        )
    }
    
    func updateDetails(_ details: [DetailsContent]) {
        detailsActiveModel.update(
            details: details
        )?.sinkWithDefaultCompletion("Emoji setDetails remove icon emoji") { _ in
            return
        }
        .store(in: &subscriptions)
    }
    
}
