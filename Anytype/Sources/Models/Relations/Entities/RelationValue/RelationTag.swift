import Foundation
import BlocksModels
import SwiftUI

extension Relation {
    
    struct Tag: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let selectedTags: [Option]
        let allTags: [Option]
    }
    
}

extension Relation.Tag {
    
    struct Option: Hashable, Identifiable, RelationSectionedOptionProtocol, RelationOptionProtocol {
        let id: String
        let text: String
        let textColor: UIColor
        let backgroundColor: UIColor
        let scope: RelationMetadata.Option.Scope
        
        func makeView() -> AnyView {
            AnyView(TagRelationRowView(tag: self))
        }
    }
    
}

extension Relation.Tag.Option {
    
    init(option: RelationMetadata.Option) {
        self.id = option.id
        self.text = option.text
        self.textColor = MiddlewareColor(rawValue: option.color)
            .map { UIColor.Text.uiColor(from: $0) } ?? .grayscale90
        self.backgroundColor = MiddlewareColor(rawValue: option.color)
            .map { UIColor.BlockBackground.uiColor(from: $0) } ?? .grayscaleWhite
        self.scope = option.scope
    }
    
}
