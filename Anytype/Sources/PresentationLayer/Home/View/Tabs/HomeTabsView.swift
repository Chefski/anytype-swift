import SwiftUI
import Amplitude
import SwiftUIVisualEffects
import AnytypeCore

extension HomeTabsView {
    enum Tab: String {
        case favourites
        case history
        case sets
        case shared
        case bin
    }
}

struct HomeTabsView: View {
    private let cornerRadius: CGFloat = 16

    @EnvironmentObject var model: HomeViewModel
    @State private var tabSelection = UserDefaultsConfig.selectedTab
    
    let offsetChanged: (CGPoint) -> Void
    let onDrag: (CGSize) -> Void
    let onDragEnd: (CGSize) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HomeTabsHeader(tabSelection: $tabSelection, onTabSelection: onTabSelection)
                .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                .highPriorityGesture(
                    DragGesture(coordinateSpace: .named(model.bottomSheetCoordinateSpaceName))
                        .onChanged { gesture in
                            onDrag(gesture.translation)
                        }
                        .onEnded{ gesture in
                            onDragEnd(gesture.translation)
                        }
                )
            tabs
            selectionViewStub
        }
    }
    
    // stub for DashboardSelectionActionsView
    private var selectionViewStub: some View {
        Group {
            if model.isSelectionMode {
                Color.clear.frame(height: DashboardSelectionActionsView.height)
            } else {
                EmptyView()
            }
        }
    }
    
    private var tabs: some View {
        TabView(selection: $tabSelection) {
            HomeCollectionView(
                cellData: model.notDeletedFavoritesCellData,
                dragAndDropDelegate: model,
                offsetChanged: offsetChanged,
                onTap: { data in
                    model.showPage(pageId: data.destinationId, viewType: data.viewType)
                }
            )
            .tag(Tab.favourites)
            
            HomeCollectionView(
                cellData: model.historyCellData,
                dragAndDropDelegate: nil, // no dnd
                offsetChanged: offsetChanged,
                onTap: { data in
                    model.showPage(pageId: data.destinationId, viewType: data.viewType)
                }
            )
            .tag(Tab.history)
            
            if FeatureFlags.sets {
                HomeCollectionView(
                    cellData: model.setsCellData,
                    dragAndDropDelegate: nil, // no dnd
                    offsetChanged: offsetChanged,
                    onTap: { data in
                        model.showPage(pageId: data.destinationId, viewType: data.viewType)
                    }
                )
                .tag(Tab.sets)
            }
            
            if AccountConfigurationProvider.shared.config.enableSpaces {
                HomeCollectionView(
                    cellData: model.sharedCellData,
                    dragAndDropDelegate: nil, // no dnd
                    offsetChanged: offsetChanged,
                    onTap: { data in
                        model.showPage(pageId: data.destinationId, viewType: data.viewType)
                    }
                )
                .tag(Tab.shared)
            }
            
            HomeCollectionView(
                cellData: model.binCellData,
                dragAndDropDelegate: nil, // no dnd
                offsetChanged: offsetChanged,
                onTap: { data in
                    UISelectionFeedbackGenerator().selectionChanged()
                    model.select(data: data)
                }
            )
            .tag(Tab.bin)
        }
        .background(BlurEffect())
        .blurEffectStyle(UIBlurEffect.Style.systemMaterial)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        .onChange(of: tabSelection) { tab in
            UserDefaultsConfig.selectedTab = tab
            onTabSelection()
        }
    }
    
    private func onTabSelection() {
        model.selectAll(false)
        
        switch tabSelection {
        case .favourites:
            Amplitude.instance().logEvent(AmplitudeEventsName.favoritesTabSelected)
            break // updates via subscriptions
        case .history:
            Amplitude.instance().logEvent(AmplitudeEventsName.recentTabSelected)
            model.updateHistoryTab()
        case .bin:
            Amplitude.instance().logEvent(AmplitudeEventsName.archiveTabSelected)
            model.updateBinTab()
        case .shared:
            Amplitude.instance().logEvent(AmplitudeEventsName.sharedTabSelected)
            model.updateSharedTab()
        case .sets:
            Amplitude.instance().logEvent(AmplitudeEventsName.setsTabSelected)
            model.updateSetsTab()
        }
    }
}

struct HomeTabsView_Previews: PreviewProvider {
    static var model: HomeViewModel {
        let model = HomeViewModel()
        return model
    }
    
    static var previews: some View {
        ZStack {
            Color.blue
            HomeTabsView(offsetChanged: { _ in }, onDrag: { _ in}, onDragEnd: { _ in })
                .environmentObject(model)
        }
    }
}
