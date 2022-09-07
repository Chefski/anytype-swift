import SwiftUI
import BlocksModels
import Combine
import AnytypeCore

final class EditorSetViewPickerViewModel: ObservableObject {
    @Published var rows: [EditorSetViewRowConfiguration] = []
    
    private let setModel: EditorSetViewModel
    private var cancellable: AnyCancellable?
    
    private let showViewTypes: RoutingAction<DataviewView>
    
    init(setModel: EditorSetViewModel, showViewTypes: @escaping RoutingAction<DataviewView>) {
        self.setModel = setModel
        self.showViewTypes = showViewTypes
        self.cancellable = setModel.$dataView.sink { [weak self] dataView in
            self?.updateRows(with: dataView)
        }
    }
    
    private func updateRows(with dataView: BlockDataview) {
        rows = dataView.views.map { view in
            EditorSetViewRowConfiguration(
                id: view.id,
                name: view.name,
                typeName: view.type.name.lowercased(),
                isSupported: view.type.isSupported,
                isActive: view == dataView.views.first { $0.id == dataView.activeViewId },
                onTap: { [weak self] in
                    self?.handleTap(with: view.id)
                },
                onEditTap: { [weak self] in
                    self?.handleEditTap(with: view.id)
                }
            )
        }
    }
    
    private func handleTap(with id: String) {
        setModel.updateActiveViewId(id)
    }
    
    private func handleEditTap(with id: String) {
        guard let activeView = setModel.dataView.views.first(where: { $0.id == id }) else {
            return
        }
        showViewTypes(activeView)
    }
}
