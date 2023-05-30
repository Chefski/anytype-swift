import SwiftUI
import Services

struct LinkToObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: LinkToObjectSearchViewModel.SearchKind
    
    let title: String
    let description: String
    let callout: String
    let typeId: String
    
    let iconImage: ObjectIconImage
    
    let viewType: EditorViewType

    init(details: ObjectDetails, searchKind: LinkToObjectSearchViewModel.SearchKind? = nil) {
        self.searchKind = searchKind ?? .object(details.id)
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.name
        self.typeId = details.objectType.id
        self.iconImage = details.objectIconImageWithPlaceholder
        self.viewType = details.editorViewType
    }

    init(searchKind: LinkToObjectSearchViewModel.SearchKind, searchTitle: String, iconImage: ObjectIconImage) {
        self.searchKind = searchKind
        self.title = searchTitle
        self.iconImage = iconImage
        self.description = ""
        self.callout = ""
        self.typeId = ""
        self.viewType = .page
    }
    
}

extension LinkToObjectSearchData {
    
    var shouldShowDescription: Bool {
        switch searchKind {
        case .object, .openObject: return description.isNotEmpty
        case .web, .createObject, .removeLink, .copyLink, .openURL: return false
        }
    }
    
    var descriptionTextColor: Color {
        .Text.primary
    }
    
    var descriptionFont: AnytypeFont {
        .relation3Regular
    }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .object: return callout.isNotEmpty
        case .web, .createObject, .openURL, .openObject, .removeLink, .copyLink: return false
        }
    }
    
    var verticalInset: CGFloat {
        20
    }

    var usecase: ObjectIconImageUsecase {
        switch searchKind {
        case .object, .openObject: return .dashboardSearch
        case .web, .createObject, .removeLink, .openURL, .copyLink: return .mention(.heading)
        }
    }
    
}