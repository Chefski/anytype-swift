import SwiftUI
import BlocksModels

struct LinkToObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: LinkToObjectSearchViewModel.SearchKind
    
    let title: String
    let description: String
    let callout: String
    let typeUrl: String
    
    let iconImage: ObjectIconImage
    
    let viewType: EditorViewType

    init(details: ObjectDetails) {
        self.searchKind = .object(details.id)
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.name
        self.typeUrl = details.objectType.url

        if details.layout == .todo {
            self.iconImage = .todo(details.isDone)
        } else {
            self.iconImage = details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
        }
        
        self.viewType = details.editorViewType
    }

    init(searchKind: LinkToObjectSearchViewModel.SearchKind, searchTitle: String, iconImage: ObjectIconImage) {
        self.searchKind = searchKind
        self.title = searchTitle
        self.iconImage = iconImage
        self.description = ""
        self.callout = ""
        self.typeUrl = ""
        self.viewType = .page
    }
    
}

extension LinkToObjectSearchData {
    
    var shouldShowDescription: Bool {
        switch searchKind {
        case .object: return description.isNotEmpty
        case .web, .createObject: return false
        }
    }
    
    var descriptionTextColor: Color {
        .textPrimary
    }
    
    var descriptionFont: AnytypeFont {
        .relation3Regular
    }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .object: return callout.isNotEmpty
        case .web, .createObject: return false
        }
    }
    
    var calloutFont: AnytypeFont {
        .relation3Regular
    }
    
    var verticalInset: CGFloat {
        20
    }

    var usecase: ObjectIconImageUsecase {
        switch searchKind {
        case .object: return .dashboardSearch
        case .web, .createObject: return .mention(.heading)
        }
    }
    
}
