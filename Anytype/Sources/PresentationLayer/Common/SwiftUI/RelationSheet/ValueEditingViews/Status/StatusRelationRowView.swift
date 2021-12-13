import SwiftUI

struct StatusRelationRowView: View {
    
    let status: NewRelation.Status.Option
    let isSelected: Bool
    let onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer.fixedHeight(14)
            content
            Spacer.fixedHeight(14)
        }
        .modifier(DividerModifier(spacing: 0))
    }
    
    private var content: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(status.text, style: .relation1Regular, color: status.color.asColor)
                Spacer()
                
                if isSelected {
                    Image.optionChecked.foregroundColor(.textSecondary)
                }
            }
            .frame(height: 20)
        }
    }
}

struct StatusRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationRowView(status: NewRelation.Status.Option(id: "", text: "text", color: .pureTeal, scope: .local), isSelected: true, onTap: {})
    }
}
