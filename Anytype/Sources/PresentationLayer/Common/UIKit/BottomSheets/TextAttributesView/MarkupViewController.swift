import UIKit


final class MarkupsViewController: UIViewController {

    private let backdropView = UIView()
    let containerView = UIView()

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.distribution = .fillEqually

        return containerStackView
    }()

    private var topStackView: UIStackView = {
        let leftTopStackView = UIStackView()
        leftTopStackView.axis = .horizontal
        leftTopStackView.distribution = .fillEqually

        return leftTopStackView
    }()

    private var middleStackView: UIStackView = {
        let leftBottomStackView = UIStackView()
        leftBottomStackView.axis = .horizontal
        leftBottomStackView.distribution = .fillEqually

        return leftBottomStackView
    }()

    private var bottomStackView: UIStackView = {
        let leftStackView = UIStackView()
        leftStackView.axis = .horizontal
        leftStackView.distribution = .fillEqually

        return leftStackView
    }()
    
    private lazy var boldButton = makeButton(image: .textAttributes.bold) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.bold))
    }.addBorders(edges: [.right, .bottom], width: 1, color: .stroke)

    private lazy var italicButton = makeButton(image: .textAttributes.italic) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.italic))
    }.addBorders(edges: [.right, .bottom], width: 1, color: .stroke)

    private lazy var strikethroughButton = makeButton(image: .textAttributes.strikethrough) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.strikethrough))
    }.addBorders(edges: [.bottom], width: 1, color: .stroke)

    private lazy var codeButton = makeButton(text: "Code".localized) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.keyboard))
    }.addBorders(edges: [.right, .bottom], width: 1, color: .stroke)

    private lazy var urlButton = makeButton(text: "Link".localized, action: {})
        .addBorders(edges: [.bottom], width: 1, color: .stroke)

    private lazy var leftAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .textAttributes.alignLeft)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.left))
        }), for: .touchUpInside)
        return button
    }()
    private lazy var centerAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .textAttributes.alignCenter)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.center))
        }), for: .touchUpInside)
        return button
    }()
    private lazy var rightAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .textAttributes.alignRight)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.right))
        }), for: .touchUpInside)
        return button
    }()

    private let viewModel: MarkupViewModelProtocol
    private let viewDidCloseHandler: () -> Void

    // MARK: - Lifecycle
    init(viewModel: MarkupViewModelProtocol, viewDidClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.viewDidCloseHandler = viewDidClose
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        viewModel.viewLoaded()
    }

    // MARK: -  Setup views

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12.0
        containerView.layer.cornerCurve = .continuous

        containerView.layer.shadowColor = UIColor.grayscale90.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowRadius = 40

        view.backgroundColor = .clear
        backdropView.backgroundColor = .clear
        let tapGeastureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backdropViewTapped))
        backdropView.addGestureRecognizer(tapGeastureRecognizer)

        view.addSubview(backdropView)
        view.addSubview(containerView)

        backdropView.pinAllEdges(to: view)

        containerView.addSubview(containerStackView) {
            $0.pinToSuperview()
        }

        containerStackView.addArrangedSubview(topStackView)
        containerStackView.addArrangedSubview(middleStackView)
        containerStackView.addArrangedSubview(bottomStackView)

        topStackView.addArrangedSubview(boldButton)
        topStackView.addArrangedSubview(italicButton)
        topStackView.addArrangedSubview(strikethroughButton)

        middleStackView.addArrangedSubview(codeButton)
        middleStackView.addArrangedSubview(urlButton)

        bottomStackView.addArrangedSubview(leftAlignButton)
        bottomStackView.addArrangedSubview(centerAlignButton)
        bottomStackView.addArrangedSubview(rightAlignButton)

        codeButton.label.font = .uxBodyRegular
        codeButton.label.textColor = .textPrimary
        urlButton.label.font = .uxBodyRegular
        urlButton.label.textColor = .textPrimary
    }
    
    private func makeButton(
        image: UIImage? = nil,
        text: String? = nil,
        action: @escaping () -> Void
    ) -> ButtonWithImage {
        let button = ButtonsFactory.makeButton(image: image, text: text)
        button.addAction(UIAction(handler: { _ in
            action()
        }), for: .touchUpInside)
        return button
    }
    
    private func setup(button: ButtonWithImage, with state: MarkupState) {
        button.isEnabled = state != .disabled
        button.isSelected = state == .applied
    }

    @objc private func backdropViewTapped() {
       dismiss()
    }
}

extension MarkupsViewController: MarkupViewProtocol {
    
    func setMarkupState(_ state: AllMarkupsState) {
        DispatchQueue.main.async {
            self.setup(button: self.boldButton, with: state.bold)
            self.setup(button: self.italicButton, with: state.italic)
            self.setup(button: self.strikethroughButton, with: state.strikethrough)
            self.setup(button: self.codeButton, with: state.codeStyle)
            self.urlButton.isEnabled = false

            self.setup(button: self.leftAlignButton, with: state.alignment[.left, default: .disabled])
            self.setup(button: self.centerAlignButton, with: state.alignment[.center, default: .disabled])
            self.setup(button: self.rightAlignButton, with: state.alignment[.right, default: .disabled])
        }
    }
    
    func dismiss() {
        removeFromParentEmbed()
        viewDidCloseHandler()
    }
}
