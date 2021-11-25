import SwiftUI
import Amplitude


struct KeychainPhraseView: View {
    @State private var showSnackbar = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(58)
            AnytypeText("Back up your keychain phrase".localized, style: .title, color: .textPrimary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(25)
            AnytypeText("Keychain phrase description".localized, style: .uxBodyRegular, color: .textPrimary)
            Spacer.fixedHeight(34)
            SeedPhraseView { showSnackbar = true }
            Spacer()
        }
        .cornerRadius(12)
        .padding([.leading, .trailing])
        .onAppear {
            Amplitude.instance().logEvent(AmplitudeEventsName.showKeychainPhraseScreen)
        }
        .snackbar(
            isShowing: $showSnackbar,
            text: AnytypeText("Keychain phrase copied to clipboard".localized, style: .uxCalloutRegular, color: .textPrimary)
        )

    }
}

struct SaveRecoveryPhraseView_Previews: PreviewProvider {    
    static var previews: some View {
        return KeychainPhraseView()
    }
}
