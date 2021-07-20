import Combine
import UIKit
import BlocksModels

final class CustomTextView: UIView {
    
    weak var delegate: TextViewDelegate?
    weak var userInteractionDelegate: TextViewUserInteractionProtocol? {
        didSet {
            textView.userInteractionDelegate = userInteractionDelegate
            accessoryViewSwitcher.handler.delegate = userInteractionDelegate
        }
    }
    
    var textSize: CGSize?

    private(set) lazy var textView = createTextView()
    let accessoryViewSwitcher: AccessoryViewSwitcher
    
    private var firstResponderSubscription: AnyCancellable?

    let options: CustomTextViewOptions
    
    init(
        options: CustomTextViewOptions,
        accessoryViewSwitcher: AccessoryViewSwitcher
    ) {
        self.options = options
        self.accessoryViewSwitcher = accessoryViewSwitcher
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .zero
    }
    
    func setupView() {
        textView.delegate = self

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }
}

// MARK: - BlockTextViewInput

extension CustomTextView: TextViewManagingFocus {
    
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ focus: BlockFocusPosition?) {
        guard let focus = focus else { return }
        
        textView.setFocus(focus)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard textView.isFirstResponder else { return nil }
        let caretLocation = textView.selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(textView.selectedRange)
    }
}

// MARK: - Views

extension CustomTextView {
    func createTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(frame: .zero, textContainer: nil) { [weak self] change in
            self?.delegate?.changeFirstResponderState(change)
        }
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.autocorrectionType = options.autocorrect ? .yes : .no
        return textView
    }
}
