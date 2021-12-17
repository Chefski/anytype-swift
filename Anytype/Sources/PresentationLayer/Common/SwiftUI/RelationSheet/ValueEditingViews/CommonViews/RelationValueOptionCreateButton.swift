import SwiftUI

struct RelationValueOptionCreateButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image.Relations.createOption.frame(width: 24, height: 24)
                AnytypeText("\("Create option".localized) \"\(text)\"", style: .uxBodyRegular, color: .textSecondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 14)
        }
        .modifier(DividerModifier(spacing: 0))
    }
}

struct RelationValueOptionCreateButton_Previews: PreviewProvider {
    static var previews: some View {
        RelationValueOptionCreateButton(text: "tetet") {}
    }
}
