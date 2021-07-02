import UIKit
import Combine
import BlocksModels

final class BlockImageContentView: UIView & UIContentView {
    
    private var imageContentViewHeight: NSLayoutConstraint?
    
    private let imageView = UIImageView()
    private let emptyView = BlocksFileEmptyView(
        viewData: .init(
            image: UIImage.blockFile.empty.image,
            placeholderText: Constants.emptyViewPlaceholderTitle
        )
    )
    
    private var onLayoutSubviewsSubscription: AnyCancellable?
    
    private var currentConfiguration: BlockImageConfiguration!
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockImageConfiguration, currentConfiguration != configuration else {
                return
            }
            self.apply(configuration: configuration)
        }
    }

    init(configuration: BlockImageConfiguration) {
        super.init(frame: .zero)
        
        setupUIElements()
        configuration.imageLoader.configured(imageView)
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUIElements() {
        /// Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(emptyView)
        addSubview(imageView)
    }
    
    private func apply(configuration: BlockImageConfiguration) {
        guard currentConfiguration != configuration else { return }
        let oldConfiguration = currentConfiguration
        currentConfiguration = configuration
        
        configuration.imageLoader.cleanupSubscription()
        handleFile(currentConfiguration.fileData, oldConfiguration?.fileData)
    }
    
    /// MARK: - EditorModuleDocumentViewCellContentConfigurationsCellsListenerProtocol
    private func refreshImage() {
        handleFile(currentConfiguration.fileData, .none)
    }
    
    private func handleFile(_ file: BlockFile, _ oldFile: BlockFile?) {

        switch file.state {
        case .empty:
            self.imageView.removeFromSuperview()
            self.addSubview(emptyView)
            self.addEmptyViewLayout()
            self.emptyView.change(state: .empty)
        case .uploading:
            self.imageView.removeFromSuperview()
            self.addSubview(emptyView)
            self.addEmptyViewLayout()
            self.emptyView.change(state: .uploading)
        case .done:
            self.emptyView.removeFromSuperview()
            self.addSubview(self.imageView)
            self.addImageViewLayout()
            self.setupImage(file, oldFile)
        case .error:
            self.imageView.removeFromSuperview()
            self.addSubview(self.emptyView)
            self.addEmptyViewLayout()
            self.emptyView.change(state: .error)
        }
        switch file.state {
        case .empty, .error, .uploading:
            self.emptyView.isHidden = false
            self.imageView.isHidden = true
        case .done:
            self.emptyView.isHidden = true
            self.imageView.isHidden = false
        }
        self.invalidateIntrinsicContentSize()
    }
    
    private func addImageViewLayout() {
        imageContentViewHeight = imageView.heightAnchor.constraint(equalToConstant: Layout.imageContentViewDefaultHeight)
        // We need priotity here cause cell self size constraint will conflict with ours
        //                imageContentViewHeight?.priority = .init(750)
        imageContentViewHeight?.isActive = true
        imageView.pinAllEdges(to: self, insets: Layout.imageViewInsets)
    }
    
    private func addEmptyViewLayout() {
        let view = self.emptyView
        if let superview = view.superview {
            let heightAnchor = view.heightAnchor.constraint(equalToConstant: Layout.emptyViewHeight)
            let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            // We need priotity here cause cell self size constraint will conflict with ours
            bottomAnchor.priority = .init(750)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(
                    equalTo: superview.leadingAnchor,
                    constant: Layout.emptyViewInsets.left
                ),
                view.trailingAnchor.constraint(
                    equalTo: superview.trailingAnchor,
                    constant: -Layout.emptyViewInsets.right
                ),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                bottomAnchor,
                heightAnchor
            ])
        }
    }
    
    func setupImage(_ file: BlockFile, _ oldFile: BlockFile?) {
        guard !file.metadata.hash.isEmpty else { return }
        let imageId = file.metadata.hash
        guard imageId != oldFile?.metadata.hash else { return }
        // We could put image into viewModel.
        // In this case we would only check
        currentConfiguration.imageLoader.update(imageId: imageId)
    }
}

private extension BlockImageContentView {
    enum Layout {
        static let imageContentViewDefaultHeight: CGFloat = 250
        static let imageViewTop: CGFloat = 4
        static let emptyViewHeight: CGFloat = 52
        static let emptyViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        static let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    }
    
    enum Constants {
        static let emptyViewPlaceholderTitle = "Add link or Upload a picture"
    }
}
