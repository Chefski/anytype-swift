import SwiftUI

struct DashboardDeletionAlert: View {
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        FloaterAlertView(
            title: Loc.areYouSureYouWantToDelete(model.numberOfSelectedPages),
            description: Loc.theseObjectsWillBeDeletedIrrevocably,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondary) {
                model.showPagesDeletionAlert = false
            },
            rightButtonData: StandardButtonModel(text: "Delete", style: .destructive) {
                model.pagesDeleteConfirmation()
            }
        )
    }
}
