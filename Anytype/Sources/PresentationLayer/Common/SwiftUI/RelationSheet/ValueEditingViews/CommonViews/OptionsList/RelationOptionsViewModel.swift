import Foundation
import SwiftUI

final class RelationOptionsViewModel: ObservableObject {
    
    var dismissHandler: (() -> Void)?
    
    @Published var isPresented: Bool = false
    @Published var selectedOptions: [RelationOptionProtocol] = []
    
    let title: String
    let emptyPlaceholder: String
    
    private let type: RelationOptionsType
    private let relationKey: String
    private let relationsService: RelationsServiceProtocol
    private var editingActions: [RelationOptionEditingAction] = []
    
    init(
        type: RelationOptionsType,
        title: String,
        relationKey: String,
        selectedOptions: [RelationOptionProtocol],
        relationsService: RelationsServiceProtocol
    ) {
        self.type = type
        self.title = title
        self.emptyPlaceholder = type.placeholder
        self.relationKey = relationKey
        self.selectedOptions = selectedOptions
        self.relationsService = relationsService
    }
    
}

extension RelationOptionsViewModel {
    
    func postponeEditingAction(_ action: RelationOptionEditingAction) {
        editingActions.append(action)
    }
    
    func applyEditingActions() {
        editingActions.forEach {
            switch $0 {
            case .remove(let indexSet):
                selectedOptions.remove(atOffsets: indexSet)
            case .move(let source, let destination):
                selectedOptions.move(fromOffsets: source, toOffset: destination)
            }
        }
        
        relationsService.updateRelation(
            relationKey: relationKey,
            value: selectedOptions.map { $0.id }.protobufValue
        )
        
        editingActions = []
    }
    
    func makeSearchView() -> AnyView {
        switch type {
        case .objects:
            return AnyView(RelationObjectsSearchView(viewModel: objectsSearchViewModel))
        case .tags(let allTags):
            return AnyView(TagRelationOptionSearchView(viewModel: searchViewModel(allTags: allTags)))
        case .files:
            return AnyView(RelationFilesSearchView(viewModel: filesSearchViewModel))
        }
    }
    
    private var objectsSearchViewModel: RelationObjectsSearchViewModel {
        RelationObjectsSearchViewModel(
            excludeObjectIds: selectedOptions.map { $0.id }
        ) { [weak self] ids in
            self?.handleNewOptionIds(ids)
        }
    }
    
    private func searchViewModel(allTags: [Relation.Tag.Option]) -> TagRelationOptionSearchViewModel {
        TagRelationOptionSearchViewModel(
            relationKey: relationKey,
            availableTags: allTags.filter { tag in
                !selectedOptions.contains { $0.id == tag.id }
            },
            relationsService: relationsService
        ) { [weak self] ids in
            self?.handleNewOptionIds(ids)
        }
    }
    
    private var filesSearchViewModel: RelationFilesSearchViewModel {
        RelationFilesSearchViewModel(excludeObjectIds: selectedOptions.map { $0.id }) { [weak self] ids in
            self?.handleNewOptionIds(ids)
        }
    }
    
    private func handleNewOptionIds(_ ids: [String]) {
        let newSelectedOptionsIds = selectedOptions.map { $0.id } + ids
        
        relationsService.updateRelation(
            relationKey: relationKey,
            value: newSelectedOptionsIds.protobufValue
        )
        
        isPresented = false
    }
    
}

extension RelationOptionsViewModel: RelationEditingViewModelProtocol {
    
    func makeView() -> AnyView {
        AnyView(RelationOptionsView(viewModel: self))
    }
    
}
