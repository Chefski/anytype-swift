import UIKit

final class DocumentIconEmojiView: UIView {
    
    // MARK: - Private properties
    
    private var menuInteractionHandler: IconMenuInteractionHandler?
    
    private let emojiLabel: UILabel = UILabel()
        
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }

}

// MARK: - ConfigurableView

extension DocumentIconEmojiView: ConfigurableView {
    
    func configure(model: IconEmoji) {
        emojiLabel.text = model.value
    }
    
}

// MARK: - IconMenuInteractableView

extension DocumentIconEmojiView: IconMenuInteractableView {
    
    func enableMenuInteraction(with onUserAction: @escaping (DocumentIconViewUserAction) -> Void) {
        let handler = IconMenuInteractionHandler(
            targetView: self,
            onUserAction: onUserAction
        )
        
        let interaction = UIContextMenuInteraction(delegate: handler)
        addInteraction(interaction)
        
        menuInteractionHandler = handler
    }
    
}

// MARK: - Private extension

private extension DocumentIconEmojiView {
    
    func setupView() {
        backgroundColor = .grayscale10
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        
        configureEmojiLabel()
        
        setUpLayout()
    }
    
    func configureEmojiLabel() {
        emojiLabel.backgroundColor = .grayscale10
        emojiLabel.font = .systemFont(ofSize: 64) // Used only for emoji
        emojiLabel.textAlignment = .center
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.isUserInteractionEnabled = false
    }
    
    func setUpLayout() {
        addSubview(emojiLabel)
        emojiLabel.pinAllEdges(to: self)
        
        layoutUsing.anchors {
            $0.size(Constants.size)
        }
    }
    
}

// MARK: - Constants

private extension DocumentIconEmojiView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 20
        static let size = CGSize(width: 96, height: 96)
    }
    
}
