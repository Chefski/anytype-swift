import SwiftUI
import Combine

struct DocumentViewWrapper: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedDocumentId: String
    @Binding var shouldShowDocument: Bool

    var body: some View {
        self.viewModel.documentView(
            selectedDocumentId: self.selectedDocumentId, shouldShowDocument: self.$shouldShowDocument
        ).navigationBarHidden(true)
    }
}
