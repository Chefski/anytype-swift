import Foundation
import BlocksModels

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    static func statusSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .singleItem,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            relationKey: relationKey,
            selectedStatusesIds: selectedStatusesIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable
        )
        
        let internalViewModel = StatusSearchViewModel(selectionMode: selectionMode, interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: style.isCreationModeAvailable ? .available(action: onCreate) : .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func tagsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            relationKey: relationKey,
            selectedTagIds: selectedTagIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable
        )
        
        let internalViewModel = TagsSearchViewModel(selectionMode: selectionMode, interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: style.isCreationModeAvailable ? .available(action: onCreate) : .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType
        )
        
        let internalViewModel = ObjectsSearchViewModel(selectionMode: selectionMode, interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func filesSearchModule(
        style: NewSearchView.Style = .default,
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedFileIds: excludedFileIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(selectionMode: .multipleItems(), interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectTypeSearchModule(
        style: NewSearchView.Style = .default,
        title: String,
        excludedObjectTypeId: String?,
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedObjectTypeId: excludedObjectTypeId
        )
        
        let internalViewModel = ObjectTypesSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            title: title,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        ) { ids in
            guard let id = ids.first else { return }
            onSelect(id)
        }
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func multiselectObjectTypesSearchModule(
        style: NewSearchView.Style = .default,
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedObjectTypeId: nil
        )
        
        let internalViewModel = MultiselectObjectTypesSearchViewModel(
            selectedObjectTypeIds: selectedObjectTypeIds,
            interactor: interactor
        )
        
        let viewModel = NewSearchViewModel(
            title: Loc.limitObjectTypes,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func moveToObjectSearchModule(
        style: NewSearchView.Style = .default,
        title: String,
        excludedObjectIds: [String],
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = MoveToSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedObjectIds: excludedObjectIds
        )

        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: .singleItem,
            interactor: interactor
        )
        let viewModel = NewSearchViewModel(
            title: title,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: { ids in
                guard let id = ids.first else { return }
                onSelect(id)
            }
        )

        return NewSearchView(viewModel: viewModel)
    }
    
    static func setSortsSearchModule(
        style: NewSearchView.Style = .default,
        relations: [Relation],
        onSelect: @escaping (_ relation: Relation) -> Void
    ) -> NewSearchView {
        let interactor = SetSortsSearchInteractor(relations: relations)
        
        let internalViewModel = SetSortsSearchViewModel(interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            searchPlaceholder: Loc.EditSet.Popup.Sort.Add.searchPlaceholder,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: { ids in
                guard let id = ids.first,
                      let relation = relations.first(where: { $0.id == id }) else { return }
                onSelect(relation)
            }
        )
        
        return NewSearchView(viewModel: viewModel)
    }
}
