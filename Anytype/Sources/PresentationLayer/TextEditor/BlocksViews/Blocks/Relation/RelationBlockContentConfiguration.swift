import UIKit

struct RelationBlockContentConfiguration: BlockConfigurationProtocol, Hashable {
    var currentConfigurationState: UICellConfigurationState?
    var relation: Relation
    
    func makeContentView() -> UIView & UIContentView {
        return RelationBlockView(configuration: self)
    }

//    static func == (lhs: RelationBlockContentConfiguration, rhs: RelationBlockContentConfiguration) -> Bool {
//        lhs.viewModel.relation == rhs.viewModel.relation &&
//        lhs.currentConfigurationState == rhs.currentConfigurationState
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(viewModel.relation)
//        hasher.combine(currentConfigurationState)
//    }
}

//}
//
//extension RelationBlockViewModelProtocol: Hashable {
//
//}
