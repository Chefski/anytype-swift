import BlocksModels
import CoreGraphics
import Combine

// MARK: - Section model

enum SearchNewRelationSectionType: Hashable, Identifiable {
    case createNewRelation
    case addFromLibriry([RelationMetadata])

    var id: Self { self }

    var headerName: String {
        switch self {
        case .createNewRelation:
            return ""
        case .addFromLibriry:
            return "Your library".localized
        }
    }
}

// MARK: - View model

class SearchNewRelationViewModel: ObservableObject, Dismissible {
    let relationService: RelationsServiceProtocol
    let usedObjectRelationsIds: Set<String> // Used for exclude relations that already has in object
    var onSelect: (RelationMetadata) -> ()
    var onDismiss: () -> () = {}

    @Published var searchData: [SearchNewRelationSectionType] = [.createNewRelation]
    @Published var shouldDismiss: Bool = false

    lazy var createNewRelationViewModel: CreateNewRelationViewModel = {
        CreateNewRelationViewModel(
            relationService: relationService,
            onSelect: { [weak self] in
                self?.shouldDismiss = true
                self?.onSelect($0)
            })
    }()

    // MARK: - Init

    init(relationService: RelationsServiceProtocol,
         objectRelations: ParsedRelations,
         onSelect: @escaping (RelationMetadata) -> ()) {
        self.relationService = relationService
        self.onSelect = onSelect

        usedObjectRelationsIds = Set(objectRelations.all.map { $0.id })
    }

    // MARK: - View model methods

    func search(text: String) {
        let newSearchData = obtainAvailbaleRelationList()

        guard !text.isEmpty else {
            searchData = newSearchData
            return
        }

        newSearchData.forEach { section in
            guard case let .addFromLibriry(relationsMetadata) = section else { return }

            let filteredRelationsMetadata = relationsMetadata.filter { relationMetadata in
                relationMetadata.name.contains(text)
            }

            searchData = [.addFromLibriry(filteredRelationsMetadata)]
        }
    }

    func obtainAvailbaleRelationList() -> [SearchNewRelationSectionType] {
        let relatonsMetadata = relationService.availableRelations()?.filter {
            !$0.isHidden && !usedObjectRelationsIds.contains($0.id)
        } ?? []
        return [.createNewRelation, .addFromLibriry(relatonsMetadata)]
    }

    func addRelation(_ relation: RelationMetadata) {
        if let createdRelation = relationService.addRelation(relation) {
            onSelect(createdRelation)
        }
    }
}
