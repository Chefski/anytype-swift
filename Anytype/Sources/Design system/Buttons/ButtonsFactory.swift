
import UIKit


enum ButtonsFactory {
    typealias ActionHandler = (_ action: UIAction) -> Void
    
    static func makeBackButton(actionHandler: @escaping ActionHandler) -> UIButton {
        let backButton = UIButton(type: .system, primaryAction: UIAction { action in
            actionHandler(action)
        })
        backButton.setAttributedTitle(
            NSAttributedString(
                string: "Back".localized,
                attributes: [.font: UIFont.caption1Regular]
            ),
            for: .normal
        )
        backButton.setImage(.backArrow, for: .normal)
        backButton.tintColor = .textSecondary
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.borderless()
            configuration.imagePadding = 10
            backButton.configuration = configuration
        } else {
            backButton.imageEdgeInsets = UIEdgeInsets(
                top: backButton.imageEdgeInsets.top,
                left: backButton.imageEdgeInsets.left,
                bottom: backButton.imageEdgeInsets.bottom,
                right: 10
            )
        }
        
        return backButton
    }
    
    static func makeButton(image: UIImage? = nil, text: String? = nil) -> ButtonWithImage {
        let button = ButtonWithImage()
        button.setImage(image)
        button.setText(text ?? "")
        button.setBackgroundColor(.clear, state: .normal)
        button.setBackgroundColor(.clear, state: .disabled)
        button.setBackgroundColor(.selected, state: .selected)
        button.setImageTintColor(.buttonInactive, state: .disabled)
        button.setImageTintColor(.textPrimary, state: .normal)

        return button
    }

    static func roundedBorderуButton(image: UIImage?) -> ButtonWithImage {
        let button = makeButton(image: image)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.grayscale30.cgColor
        button.contentMode = .center
        button.imageView.contentMode = .scaleAspectFit

        return button
    }
}
