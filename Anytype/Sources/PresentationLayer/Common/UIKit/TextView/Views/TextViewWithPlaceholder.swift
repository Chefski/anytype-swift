import UIKit


final class TextViewWithPlaceholder: UITextView {
    private enum InsetEdgeType {
        case top
        case bottom
        case left
        case right
    }
    
    // MARK: - Views
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        return label
    }()

    private var placeholderConstraints: [InsetEdgeType: NSLayoutConstraint] = [:]
    private let blockLayoutManager = TextBlockLayoutManager()
    private let onFirstResponderChange: (CustomTextViewFirstResponderChange) -> ()

    // MARK: - Internal variables
    
    weak var customTextViewDelegate: CustomTextViewDelegate?

    /// Custom color that applyed after `primaryColor`and `foregroundColor`
    var tertiaryColor: UIColor? {
        didSet {
            blockLayoutManager.tertiaryColor = tertiaryColor
        }
    }

    /// Default font color. Applied as the lowest priority color.
    var defaultFontColor: UIColor? {
        didSet {
            blockLayoutManager.defaultColor = defaultFontColor
        }
    }

    /// Color for selected state
    var selectedColor: UIColor? {
        didSet {
            blockLayoutManager.primaryColor = selectedColor
        }
    }

    // MARK: - Overrides
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderLayout()
        }
    }

    override var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            if let font = super.typingAttributes[.font] as? UIFont {
                placeholderLabel.font = font
            }
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()


        reloadGestures()
        onFirstResponderChange(.become)
        return value
    }

    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        onFirstResponderChange(.resign)
        if value {
            UIMenuController.shared.menuItems = nil
        }

        reloadGestures()
        return value
    }

    // MARK: - Initialization
        
    init(
        frame: CGRect,
        textContainer: NSTextContainer?,
        onFirstResponderChange: @escaping (CustomTextViewFirstResponderChange) -> ()
    ) {
        self.onFirstResponderChange = onFirstResponderChange
        
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(blockLayoutManager)
        let container = textContainer ?? NSTextContainer()
        blockLayoutManager.addTextContainer(container)

        super.init(frame: frame, textContainer: container)

        self.setup()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        fatalError("Not implemented")
    }
    

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

// MARK: - Private extension

private extension TextViewWithPlaceholder {
    
    func setup() {
        textStorage.delegate = self
        addSubview(placeholderLabel)
        
        placeholderLabel.layoutUsing.anchors {
            placeholderConstraints[.left] = $0.leading.equal(to: leadingAnchor, constant: textContainerInset.left)
            placeholderConstraints[.right] = $0.trailing.equal(to: trailingAnchor, constant: -textContainerInset.right)
            placeholderConstraints[.top] = $0.top.equal(to: topAnchor, constant: textContainerInset.top)
            placeholderConstraints[.bottom] = $0.bottom.equal(to: bottomAnchor, constant: -textContainerInset.bottom)
            $0.width.equal(to: widthAnchor).priority = .defaultHigh - 1
        }
        placeholderLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }

    func updatePlaceholderLayout() {
        placeholderConstraints[.left]?.constant = textContainerInset.left
        placeholderConstraints[.right]?.constant = textContainerInset.right
        placeholderConstraints[.top]?.constant = textContainerInset.top
        placeholderConstraints[.bottom]?.constant = textContainerInset.bottom
    }
    
    private func syncPlaceholder() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
}

// MARK: - Contextual Menu

extension TextViewWithPlaceholder {
    
    @objc private func didSelectContextMenuActionBold() {
        handleMenuAction(.bold)
    }
    
    @objc private func didSelectContextMenuActionItalic() {
        handleMenuAction(.italic)
    }
    
    @objc private func didSelectContextMenuActionStrikethrough() {
        handleMenuAction(.strikethrough)
    }
    
    @objc private func didSelectContextMenuActionCode() {
        handleMenuAction(.keyboard)
    }

    private func handleMenuAction(_ action: MarkupType) {
        customTextViewDelegate?.changeTextStyle(attribute: action, range: selectedRange)
    }
}

// MARK: - NSTextStorageDelegate

extension TextViewWithPlaceholder: NSTextStorageDelegate {
    // We can't use this delegate func to update our block model as we don't know source of changes (middleware or user).
    // If in future we want here change attributes then we should send command to middleware.
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.syncPlaceholder()
    }
}

extension TextViewWithPlaceholder {
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            gestureRecognizer.isEnabled = isFirstResponder
        }
        return super.addGestureRecognizer(gestureRecognizer)
    }

    func reloadGestures() {
        gestureRecognizers?.forEach {
            if $0.isKind(of: UILongPressGestureRecognizer.self) {
                $0.isEnabled = isFirstResponder
            }
        }
    }

}
// MARK: - Placeholder

extension TextViewWithPlaceholder {
    
    func update(placeholder: NSAttributedString?) {
        placeholderLabel.attributedText = placeholder
    }
}