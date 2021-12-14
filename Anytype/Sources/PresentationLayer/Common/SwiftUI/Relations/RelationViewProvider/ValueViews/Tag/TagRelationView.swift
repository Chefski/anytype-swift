import SwiftUI

struct TagRelationView: View {
    let tags: [Relation.Tag.Option]
    let hint: String
    let style: RelationStyle

    var body: some View {
        if tags.isNotEmpty {
            if maxTags > 0 {
                withMoreTagsView
            } else {
                scrollRelations
            }
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
        }
    }

    private var scrollRelations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: hSpacing) {
                contnetView(tags: tags)
            }
            .padding(.horizontal, 1)
        }
    }

    private var withMoreTagsView: some View {
        var newTags = tags
        if maxTags > 0 {
            newTags = Array(tags.prefix(maxTags))
        }

        return HStack(spacing: hSpacing) {
            contnetView(tags: newTags)
            moreTagsView
        }
        .padding(.horizontal, 1)
    }

    private func contnetView(tags: [Relation.Tag.Option]) -> some View {
        ForEach(tags) { tag in
            TagView(tag: tag, guidlines: style.tagViewGuidlines)
        }
    }

    private var moreTagsView: some View {
        let leftTagsCount = "+\(tags.count - maxTags)"

        return AnytypeText(leftTagsCount, style: .relation2Regular, color: .textSecondary)
            .lineLimit(1)
            .frame(width: 24, height: 19)
            .background(Color.grayscale10)
            .cornerRadius(3)
    }
}

private extension TagRelationView {
    
    private var maxTags: Int {
        switch style {
        case .regular, .set: return 0
        case .featuredRelationBlock: return 3
        }
    }
    
    private var hSpacing: CGFloat {
        switch style {
        case .regular, .set: return 8
        case .featuredRelationBlock: return 6
        }
    }
}

struct TagRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationView(
            tags: [
                Relation.Tag.Option(id: "id1", text: "text1", textColor: .darkTeal, backgroundColor: .grayscaleWhite, scope: .local),
                Relation.Tag.Option(id: "id2", text: "text2", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id3", text: "text3", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id4", text: "text4", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id5", text: "text5", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id6", text: "text6", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id7", text: "text7", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id8", text: "text8", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id9", text: "text9", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id10", text: "text10", textColor: .darkRed, backgroundColor: .lightRed, scope: .local)
            ],
            hint: "Hint",
            style: .regular(allowMultiLine: false)
        )
    }
}

