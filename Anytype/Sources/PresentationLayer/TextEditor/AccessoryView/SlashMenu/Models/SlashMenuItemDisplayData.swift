import Foundation

struct SlashMenuItemDisplayData {
    let iconData: ObjectIconImage
    let title: String
    let subtitle: String?
    let expandedIcon: Bool
    
    init(iconData: ObjectIconImage, title: String, subtitle: String? = nil, expandedIcon: Bool = false) {
        self.iconData = iconData
        self.title = title
        self.subtitle = subtitle
        self.expandedIcon = expandedIcon
    }
}


enum NewSlashMenuItemDisplayData: ComparableDisplayData {
    case titleSubtitleDisplayData(SlashMenuItemDisplayData)
    case relationDisplayData(SlashActionRelations)

    var title: String? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.title
        case let .relationDisplayData(slashActionRelations):
            switch slashActionRelations {
            case .newRealtion:
                return nil
            case let .relation(relation):
                return relation.name
            }
        }
    }

    var subtitle: String? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.subtitle
        case .relationDisplayData:
            return nil
        }
    }
}
