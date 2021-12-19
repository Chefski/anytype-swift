import SwiftUI

struct StatusRelationEditingView: View {
    
    @ObservedObject var viewModel: StatusRelationEditingViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false)
            statusesList
            Spacer.fixedHeight(20)
        }
        .modifier(RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.relationName, dismissCallback: viewModel.dismissHandler))
        .onChange(of: searchText) { viewModel.filterStatusSections(text: $0) }
    }
    
    private var statusesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchText.isNotEmpty {
                    RelationValueOptionCreateButton(text: searchText) {
                        viewModel.addOption(text: searchText)
                    }
                }
                
                ForEach(viewModel.statusSections) { section in
                    Section(
                        header: RelationValueOptionSectionHeaderView(title: section.title)
                    ) {
                        ForEach(section.options) { statusRow($0) }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func statusRow(_ status: Relation.Status.Option) -> some View {
        StatusRelationRowView(
            status: status,
            isSelected: status == viewModel.selectedStatus
        ) {
            if viewModel.selectedStatus == status {
                viewModel.selectedStatus = nil
            } else {
                viewModel.selectedStatus = status
            }
            
            viewModel.saveValue()
        }
    }
}

struct StatusRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationEditingView(
            viewModel: StatusRelationEditingViewModel(
                relationKey: "",
                relationName: "",
                relationOptions: [],
                selectedStatus: nil,
                detailsService: DetailsService(objectId: ""),
                relationsService: RelationsService(objectId: "")
            )
        )
    }
}
