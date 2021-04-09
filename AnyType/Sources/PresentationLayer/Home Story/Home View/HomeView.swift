import SwiftUI
import Combine

struct HomeView: View {
    // TODO: workaround - HomeCollectionView view model here due to SwiftUI doesn't update
    // view when it's UIViewRepresentable
    // https://forums.swift.org/t/uiviewrepresentable-not-updated-when-observed-object-changed/33890/9
    @ObservedObject private var collectionViewModel: HomeCollectionViewModel
    @ObservedObject private var viewModel: HomeViewModel
    
    @State var showDocument: Bool = false
    @State var selectedDocumentId: String = ""
    
    init(viewModel: HomeViewModel, collectionViewModel: HomeCollectionViewModel) {
        self.viewModel = viewModel
        self.collectionViewModel = collectionViewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(
                    destination: self.documentView(hasCustomModalView: false).edgesIgnoringSafeArea(.all),
                    isActive: self.$showDocument,
                    label: { EmptyView() }
                )
                self.topView
                self.collectionView
            }
            .background(
                LinearGradient(
                    gradient: Gradients.homeBackground, startPoint: .leading, endPoint: .trailing
                ).edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.gray)
        .onAppear(perform: onAppear)
    }

    private var topView: some View {
        HStack {
            Text("Hi, \(self.viewModel.profileViewModel.visibleAccountName)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.title)
            Spacer()
            NavigationLink(destination: self.viewModel.profileView) {
                UserIconView(
                    image: self.viewModel.profileViewModel.accountAvatar,
                    color: self.viewModel.profileViewModel.visibleSelectedColor,
                    name: self.viewModel.profileViewModel.visibleAccountName
                ).frame(width: 43, height: 43)
            }
        }
        .padding([.top, .trailing, .leading], 20)
    }
    
    private var collectionView: some View {
        GeometryReader { geometry in
            self.viewModel.obtainCollectionView(
                showDocument: self.$showDocument,
                selectedDocumentId: self.$selectedDocumentId,
                containerSize: geometry.size,
                homeCollectionViewModel: self.collectionViewModel,
                cellsModels: self.$collectionViewModel.documentsViewModels
            ).padding()
        }
    }
    
    private func documentView(hasCustomModalView: Bool = false) -> some View {
        DocumentViewWrapper(
            viewModel: self.viewModel, selectedDocumentId: self.$selectedDocumentId, shouldShowDocument: self.$showDocument
        )
    }

    private func onAppear() {
        self.viewModel.obtainAccountInfo()
        makeNavigationBarTransparent()
    }
    
    private func makeNavigationBarTransparent() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}
