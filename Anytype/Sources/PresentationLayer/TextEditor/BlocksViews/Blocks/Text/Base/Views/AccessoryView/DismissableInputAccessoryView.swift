import UIKit

class DismissableInputAccessoryView: UIView {

    private enum Constants {
        static let separatorHeight: CGFloat = 0.5
    }
    
    var dismissHandler: (() -> Void)?
    private(set) weak var topSeparator: UIView?
    private var transparentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        guard let window = window else {
            topSeparator?.removeFromSuperview()
            topSeparator = nil
            return
        }
        transparentView?.removeFromSuperview()
        topSeparator?.removeFromSuperview()
        addTransparentViewForDismissAction(parentView: window)
        addTopSeparator()
    }
    
    func didShow(from textView: UITextView) {}
    
    @objc private func dismiss() {
        dismissHandler?()
        removeFromSuperview()
    }
    
    private func addTopSeparator() {
        let topSeparator = UIView()
        topSeparator.backgroundColor = .systemGray4
        addSubview(topSeparator) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: Constants.separatorHeight)
        }
        self.topSeparator = topSeparator
    }
    
    private func addTransparentViewForDismissAction(parentView: UIWindow) {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        parentView.addSubview(view) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: topAnchor)
        }

        transparentView = view
    }
}
