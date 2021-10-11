import SwiftUI
import Amplitude


struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @StateObject private var settingsSectionModel = SettingSectionViewModel()
    @State private var logginOut = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            SettingsSectionView()
            Button(action: { logginOut = true }) {
                AnytypeText("Log out".localized, style: .uxCalloutRegular, color: .textSecondary)
                    .padding()
            }
        }
        .background(Color.background)
        .cornerRadius(16)
        
        .environmentObject(viewModel)
        .environmentObject(settingsSectionModel)
        
        .alert(isPresented: $logginOut) {
            alert
        }
    }
    
    private var alert: Alert {
        Alert(
            title: AnytypeText.buildText("Log out".localized, style: .title),
            message: AnytypeText.buildText("Have you backed up your keychain phrase?".localized, style: .subheading),
            primaryButton: Alert.Button.default(
                AnytypeText.buildText("Backup keychain phrase".localized, style: .bodyRegular)
            ) {
                settingsSectionModel.keychain = true
            },
            secondaryButton: Alert.Button.destructive(
                AnytypeText.buildText("Log out", style: .bodyRegular)
            ) {
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.buttonProfileLogOut)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                viewModel.logout()
            }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureAmber.ignoresSafeArea()
            SettingsView(
                viewModel: SettingsViewModel(
                    authService: ServiceLocator.shared.authService()
                )
            ).previewLayout(.fixed(width: 360, height: 276))
        }
    }
}

