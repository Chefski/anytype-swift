import SwiftUI

struct StatusRelationDetailsView: View {
    
    @ObservedObject var viewModel: StatusRelationDetailsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            InlineNavigationBar {
                TitleView(title: "Status")
            } rightButton: {
                rightButton
            }
            content
            Spacer()
        }
    }
    
    private var rightButton: some View {
        Group {
            if viewModel.currentStatusModel.isNil {
                addButton
            } else {
                clearButton
            }
        }
    }
    
    private var content: some View {
        Group {
            if let currentStatusModel = viewModel.currentStatusModel {
                StatusSearchRowView(viewModel: currentStatusModel)
            } else {
                AnytypeText("No related options here. You can add some".localized, style: .uxCalloutRegular, color: .textTertiary)
                    .frame(height: 48)
            }
        }
    }
    
}

// MARK: - NavigationBarView

private extension StatusRelationDetailsView {
    
    var clearButton: some View {
        Button {
            withAnimation(.fastSpring) {
                viewModel.didTapClearButton()
            }
        } label: {
            AnytypeText("Clear".localized, style: .uxBodyRegular, color: .buttonActive)
        }
    }
    
    var addButton: some View {
        Button {
            viewModel.didTapAddButton()
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }
    }
    
}
