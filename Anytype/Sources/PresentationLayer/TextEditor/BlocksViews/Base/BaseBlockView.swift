import UIKit

private enum Constants {
    static let selectionViewInset: UIEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)
}

class BaseBlockView<Configuration: BlockConfigurationProtocol>: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? Configuration,
                  currentConfiguration != newConfiguration else { return }

            currentConfiguration = newConfiguration

        }
    }
    var currentConfiguration: Configuration {
        didSet {
            guard didSetupSubviews else { return }
            update(with: currentConfiguration)
        }
    }

    private var didSetupSubviews = false
    private let selectionView = BaseSelectionView()

    init(configuration: Configuration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        setupSubviews()
        didSetupSubviews = true
        update(with: currentConfiguration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with configuration: Configuration) {
        configuration.currentConfigurationState.map(update(with:))
    }

    func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)

        isUserInteractionEnabled = state.isEditing
    }
    

    func setupSubviews() {
        addSubview(selectionView) {
            $0.pinToSuperview(insets: Constants.selectionViewInset)
        }
    }
}
