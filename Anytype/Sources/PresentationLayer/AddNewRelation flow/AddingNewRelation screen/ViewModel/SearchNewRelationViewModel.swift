import BlocksModels
import CoreGraphics
import Combine
import Amplitude
import AnytypeCore

final class SearchNewRelationViewModel: ObservableObject, Dismissible {
    
    var onDismiss: () -> () = {}

    @Published private(set) var searchData: [SearchNewRelationSectionType] = [.createNewRelation]
    @Published private(set) var shouldDismiss: Bool = false

    // MARK: - Private variables
    
    // Used for exclude relations that already has in object
    private let usedObjectRelationsIds: Set<String>
    private let relationService: RelationsServiceProtocol
    private weak var output: SearchNewRelationModuleOutput?
    private let onSelect: ((RelationMetadata) -> ())?
    
    // MARK: - Initializers
    
    init(
        objectRelations: ParsedRelations,
        relationService: RelationsServiceProtocol,
        output: SearchNewRelationModuleOutput?,
        onSelect: ((RelationMetadata) -> ())?
    ) {
        self.relationService = relationService
        self.output = output
        self.onSelect = onSelect

        usedObjectRelationsIds = Set(objectRelations.all.map { $0.id })
    }
    
}

// MARK: - View model methods

extension SearchNewRelationViewModel {
    
    func search(text: String) {
        Amplitude.instance().logSearchQuery(.menuSearch, length: text.count)
        
        let newSearchData = obtainAvailbaleRelationList()

        guard !text.isEmpty else {
            searchData = newSearchData
            return
        }

        newSearchData.forEach { section in
            guard case let .addFromLibriry(relationsMetadata) = section else { return }
            searchData.removeAll()

            let filteredRelationsMetadata = relationsMetadata.filter { relationMetadata in
                relationMetadata.name.contains(text)
            }
            searchData.append(.createNewRelation)

            if filteredRelationsMetadata.isNotEmpty {
                searchData.append(.addFromLibriry(filteredRelationsMetadata))
            }
        }
    }

    func obtainAvailbaleRelationList() -> [SearchNewRelationSectionType] {
        let relatonsMetadata = relationService.availableRelations()?.filter {
            !$0.isHidden && !usedObjectRelationsIds.contains($0.id)
        } ?? []
        return [.createNewRelation, .addFromLibriry(relatonsMetadata)]
    }

    func addRelation(_ relation: RelationMetadata) {
        if let createdRelation = relationService.addRelation(relation: relation) {
            if FeatureFlags.createNewRelationV2 {
                output?.didAddRelation(createdRelation)
            } else {
                onSelect?(createdRelation)
            }
        }
    }
    
    var createNewRelationViewModel: CreateNewRelationViewModel {
        CreateNewRelationViewModel(
            relationService: relationService,
            onSelect: { [weak self] in
                guard let self = self else { return }
                
                self.shouldDismiss = true
                self.onSelect?($0)
            }
        )
    }
    
    func showAddRelation(searchText: String) {
        output?.didAskToShowCreateNewRelation(searchText: searchText)
    }
    
    func newRelationViewModel(searchText: String) -> NewRelationViewModel {
        NewRelationViewModel(name: searchText, output: nil)
    }
    
}
