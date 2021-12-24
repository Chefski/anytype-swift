import SwiftUI
import Amplitude
import SwiftUIVisualEffects
import AnytypeCore

extension HomeTabsView {
    enum Tab: String, CaseIterable {
        case favourites
        case history
        case sets
        case shared
        case bin
        
        var subscriptionId: SubscriptionId? {
            switch self {
            case .favourites:
                return nil
            case .sets:
                return .sets
            case .shared:
                return .shared
            case .history:
                return .history
            case .bin:
                return .archive
            }
        }
        
        var amplitudeEventName: String {
            switch self {
            case .favourites:
                return AmplitudeEventsName.favoritesTabSelected
            case .history:
                return AmplitudeEventsName.recentTabSelected
            case .bin:
                return AmplitudeEventsName.archiveTabSelected
            case .shared:
                return AmplitudeEventsName.sharedTabSelected
            case .sets:
                return AmplitudeEventsName.setsTabSelected
            }
        }
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
            HomeTabsHeader(tabSelection: $tabSelection)
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
        .onAppear {
            onTabSelection()
        }
    }
    
    private func onTabSelection() {
        model.selectAll(false)
        model.onTabChange(tab: tabSelection)
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
