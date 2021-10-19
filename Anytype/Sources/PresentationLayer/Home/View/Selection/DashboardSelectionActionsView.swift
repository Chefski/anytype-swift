import SwiftUI
import SwiftUIVisualEffects

struct DashboardSelectionActionsView: View {
    static var height = UIApplication.shared.mainWindowInsets.bottom + 48
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        Group {
            if model.isSelectionMode {
                VStack(spacing: 0) {
                    Spacer()
                    view
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var view: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            buttons
            Spacer.fixedHeight(UIApplication.shared.mainWindowInsets.bottom + 12)
        }
        .frame(height: Self.height)
        .background(BlurEffect())
    }
    
    private var buttons: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: {
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                AnytypeText("Delete".localized, style: .uxBodyRegular, color: .textPrimary)
            })
                .frame(maxWidth: .infinity)
            
            Button(action: {
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                AnytypeText("Restore".localized, style: .uxBodyRegular, color: .textPrimary)
            })
                .frame(maxWidth: .infinity)
        }
    }
}
