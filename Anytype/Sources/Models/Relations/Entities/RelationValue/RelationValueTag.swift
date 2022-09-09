import Foundation
import BlocksModels
import SwiftUI

extension RelationValue {
    
    struct Tag: RelationValueProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let selectedTags: [Option]
        
        var hasValue: Bool {
            selectedTags.isNotEmpty
        }
    }
    
}

extension RelationValue.Tag {
    
    struct Option: Hashable, Identifiable {
        let id: String
        let text: String
        let textColor: UIColor
        let backgroundColor: UIColor
        let scope: RelationOption.Scope
    }
    
}

extension RelationValue.Tag.Option {
    
    init(option: RelationOption) {
        self.id = option.id
        self.text = option.text
        self.textColor = MiddlewareColor(rawValue: option.color)
            .map { UIColor.Text.uiColor(from: $0) } ?? .textSecondary
        self.backgroundColor = MiddlewareColor(rawValue: option.color)
            .map { UIColor.TagBackground.uiColor(from: $0) } ?? .backgroundSecondary

        self.scope = option.scope
    }
    
}
