import SwiftUI

struct RelationValueOptionSectionHeaderView: View {
    let title: String
    
    var body: some View {
        AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            .padding(.top, 26)
            .padding(.bottom, 8)
            .modifier(DividerModifier(spacing: 0, alignment: .leading))
    }
}

struct RelationValueOptionSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        RelationValueOptionSectionHeaderView(title: "title")
    }
}
