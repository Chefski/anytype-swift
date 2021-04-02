//
//  HomeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @Environment(\.developerOptions) private var developerOptions
    var homeCollectionViewAssembly: HomeCollectionViewAssembly
    @ObservedObject var profileViewModel: ProfileViewModel
    private var profileViewModelObjectWillChange: AnyCancellable?
//    var profileViewModel: ProfileViewModel {
//        self.profileViewCoordinator.viewModel
//    }
    var profileViewCoordinator: ProfileViewCoordinator
    var cachedDocumentView: AnyView?
    var documentViewId: String = ""

    init(homeCollectionViewAssembly: HomeCollectionViewAssembly, profileViewCoordinator: ProfileViewCoordinator) {
        self.homeCollectionViewAssembly = homeCollectionViewAssembly
        self.profileViewCoordinator = profileViewCoordinator
        self.profileViewModel = self.profileViewCoordinator.viewModel
        self.profileViewModelObjectWillChange = self.profileViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func createDocumentView(documentId: String) -> some View {
        EditorModule.TopLevelBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId))
    }
    
    func createDocumentView(documentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        EditorModule.TopLevelBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId), shouldShowDocument: shouldShowDocument)
    }
    
    func documentView(selectedDocumentId: String) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view: AnyView = .init(self.createDocumentView(documentId: selectedDocumentId))
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
    
    func documentView(selectedDocumentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view: AnyView = .init(self.createDocumentView(documentId: selectedDocumentId, shouldShowDocument: shouldShowDocument))
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }

    // MARK: AccountInfo
    func obtainAccountInfo() {
        self.profileViewModel.obtainAccountInfo()
//        self.profileViewCoordinator.viewModel.obtainAccountInfo()
    }

    // MARK: - View events
    func obtainCollectionView(
        showDocument: Binding<Bool>,
        selectedDocumentId: Binding<String>,
        containerSize: CGSize,
        homeCollectionViewModel: HomeCollectionViewModel,
        cellsModels: Binding<[HomeCollectionViewCellType]>
    ) -> some View {
        self.homeCollectionViewAssembly.createHomeCollectionView(showDocument: showDocument, selectedDocumentId: selectedDocumentId, containerSize: containerSize, cellsModels: cellsModels).environmentObject(homeCollectionViewModel)
    }
}
