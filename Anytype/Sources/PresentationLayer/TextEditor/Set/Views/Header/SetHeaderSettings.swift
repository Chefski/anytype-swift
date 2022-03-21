import SwiftUI

struct SetHeaderSettings: View {
    let settingsHeight: CGFloat = 56
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            viewButton
            Spacer()
            settingButton
        }
        .padding(.horizontal, 20)
        .frame(height: settingsHeight)
    }
    
    private var settingButton: some View {
        Button(action: {
            model.showViewPicker()
        }) {
            Image.set.settings
        }
    }
    
    private var viewButton: some View {
        Button(action: {
            withAnimation(.fastSpring) {
                model.showViewPicker()
            }
        }) {
            HStack(alignment: .center, spacing: 0) {
                AnytypeText(model.activeView.name, style: .subheading, color: .textPrimary)
                Spacer.fixedWidth(4)
                Image.arrowDown.foregroundColor(.textPrimary)
            }
        }
    }
}

struct SetHeaderSettings_Previews: PreviewProvider {
    static var previews: some View {
        SetHeaderSettings()
    }
}
