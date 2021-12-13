
import SwiftUI

struct SetTableViewRow: View {
    let data: SetTableViewRowData
    let initialOffset: CGFloat
    let xOffset: CGFloat
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(18)
            title
            Spacer.fixedHeight(18)
            cells
            Spacer.fixedHeight(12)
            Divider()
        }
    }
    
    private var title: some View {
        Button {
            model.router.showPage(data: data.screenData)
        } label: {
            HStack(spacing: 0) {
                if let icon = data.icon {
                    SwiftUIObjectIconImageView(iconImage: icon, usecase: .setRow).frame(width: 18, height: 18)
                    Spacer.fixedWidth(8)
                }
                AnytypeText(data.title, style: .body, color: .grayscale90)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
        }
        .offset(x: initialOffset >= xOffset ? initialOffset - xOffset : 0, y: 0)
    }
    
    private var cells: some View {
        LazyHStack(spacing: 0) {
            ForEach(data.relations) { colum in
                Spacer.fixedWidth(16)
                cell(colum)
                Rectangle()
                    .frame(width: 0.5, height: 18)
                    .foregroundColor(.grayscale30)
            }
        }
    }
    
    private func cell(_ relationData: Relation) -> some View {
        Button {
            model.router.showRelationValueEditingView(
                objectId: data.id,
                relation: relationData
            )
        } label: {
            RelationValueView(relation: relationData, style: .set)
                .frame(width: 128)
        }
    }
}

//struct SetTableViewRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SetTableViewRow(
//            data: SetTableViewRowData(id: "", type: .page, title: "Title", icon: .placeholder("f"), allRelations: [], allMetadata: [], colums: []),
//            initialOffset: 0,
//            xOffset: 0
//        )
//    }
//}
