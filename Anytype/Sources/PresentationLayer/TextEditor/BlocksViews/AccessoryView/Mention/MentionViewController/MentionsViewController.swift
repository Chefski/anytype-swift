import UIKit

protocol MentionsView: AnyObject {
    func display(_ list: [MentionDisplayData])
    func update( mention: MentionDisplayData)
    func dismiss()
}

final class MentionsViewController: UITableViewController {
    let viewModel: MentionsViewModel
    private lazy var dataSource = makeDataSource()
    private let dismissAction: (() -> Void)?
    
    init(
        viewModel: MentionsViewModel,
        dismissAction: (() -> Void)?
    ) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = Constants.separatorInsets
        tableView.rowHeight = Constants.cellHeight
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        tableView.tableFooterView = UIView(frame: .zero)
        viewModel.setup(with: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .createNewObject:
            viewModel.didSelectCreateNewMention()
        case let .mention(mention):
            viewModel.didSelectMention(mention)
        }
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<MentionSection, MentionDisplayData> {
        UITableViewDiffableDataSource<MentionSection, MentionDisplayData>(tableView: tableView) { [weak self] tableView, indexPath, displayData -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)
            switch displayData {
            case .createNewObject:
                cell.contentConfiguration = self?.createNewObjectContentConfiguration()
            case let .mention(mention):
                cell.contentConfiguration = self?.confguration(for: mention)
            }
            return cell
        }
    }
    
    private func confguration(for mention: MentionObject) -> UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: mention.name,
                subtitle: mention.type?.name ?? "Object".localized,
                icon: mention.objectIcon
            )
        )
    }
    
    private func createNewObjectContentConfiguration() -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.cell()
        configuration.text = "Create new object".localized
        configuration.textProperties.font = .uxTitle2Regular
        configuration.textProperties.color = .textSecondary
        
        configuration.image = UIImage(named: "createNewObject")
        configuration.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        configuration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        configuration.imageToTextPadding = Constants.createNewObjectImagePadding
        return configuration
    }
    
    // MARK: - Constants
    private enum Constants {
        static let cellReuseId = NSStringFromClass(UITableViewCell.self)
        static let separatorInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 20)
        static let cellHeight: CGFloat = 56
        static let createNewObjectImagePadding: CGFloat = 12
    }
}

extension MentionsViewController: MentionsView {
    
    func display(_ list: [MentionDisplayData]) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<MentionSection, MentionDisplayData>()
            snapshot.appendSections(MentionSection.allCases)
            snapshot.appendItems([.createNewObject], toSection: .first)
            snapshot.appendItems(list, toSection: .second)
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func update(mention: MentionDisplayData) {
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems([mention])
            self.dataSource.apply(snapshot)
        }
    }
    
    func dismiss() {
        dismissAction?()
    }
}
