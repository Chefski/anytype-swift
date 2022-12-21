import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsBuilder {
    
    private let storage: ObjectDetailsStorage
    
    init(storage: ObjectDetailsStorage = ObjectDetailsStorage.shared) {
        self.storage = storage
    }

    // MARK: - Private variables
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    // MARK: - Internal functions
    
    func parsedRelations(
        relationsDetails: [RelationDetails],
        objectId: BlockId,
        isObjectLocked: Bool
    ) -> ParsedRelations {
        guard
            let objectDetails = storage.get(id: objectId)
        else {
            return .empty
        }
        
        var featuredRelations: [Relation] = []
        var deletedRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        relationsDetails.forEach { relationDetails in
            guard !relationDetails.isHidden,
                    relationDetails.key != BundledRelationKey.type.rawValue
            else { return }
            
            let value = relation(
                relationDetails: relationDetails,
                details: objectDetails,
                isObjectLocked: isObjectLocked
            )
            
            if value.isFeatured {
                featuredRelations.append(value)
            } else if value.isDeleted {
                deletedRelations.append(value)
            } else {
                otherRelations.append(value)
            }
        }
        
        return ParsedRelations(featuredRelations: featuredRelations, deletedRelations: deletedRelations, otherRelations: otherRelations)
    }
    
}

// MARK: - Private extension

private extension RelationsBuilder {
    
    func relation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        switch relationDetails.format {
        case .longText:
            return textRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .shortText:
            return textRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .number:
            return numberRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .status:
            return statusRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .date:
            return dateRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .file:
            return fileRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .checkbox:
            return checkboxRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .url:
            return urlRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .email:
            return emailRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .phone:
            return phoneRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .tag:
            return tagRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .object:
            return objectRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .unrecognized:
            return .text(
                Relation.Text(
                    id: relationDetails.id,
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: relationDetails.isFeatured(details: details),
                    isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                    isSystem: relationDetails.isSystem,
                    isDeleted: relationDetails.isDeleted,
                    value: Loc.unsupportedValue
                )
            )
        }
    }
    
    func textRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .text(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func numberRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let numberValue: String? = {
            guard let number = details.doubleValue(for: relationDetails.key) else { return nil }
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: numberValue
            )
        )
    }
    
    func phoneRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .phone(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func emailRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .email(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func urlRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .url(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func statusRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        
        let selectedOption: Relation.Status.Option? = {
            let optionId = details.stringValue(for: relationDetails.key)
            
            guard optionId.isNotEmpty else { return nil }
            
            guard let optionDetails = storage.get(id: optionId) else { return nil }
            let option = RelationOption(details: optionDetails)
            return Relation.Status.Option(option: option)
        }()
        var values = [Relation.Status.Option]()
        if let selectedOption = selectedOption {
            values.append(selectedOption)
        }
        return .status(
            Relation.Status(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                values: values
            )
        )
    }
    
    func dateRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let value: DateRelationValue? = {
            guard let date = details.dateValue(for: relationDetails.key) else { return nil }
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: value
            )
        )
    }
    
    func checkboxRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .checkbox(
            Relation.Checkbox(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: details.boolValue(for: relationDetails.key)
            )
        )
    }
    
    func tagRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        
        let selectedTags: [Relation.Tag.Option] = {
            let selectedTagIds = details.stringArrayValue(for: relationDetails.key)
            
            let tags = selectedTagIds
                .compactMap { storage.get(id: $0) }
                .map { RelationOption(details: $0) }
                .map { Relation.Tag.Option(option: $0) }

            return tags
        }()
        
        return .tag(
            Relation.Tag(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func objectRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let objectOptions: [Relation.Object.Option] = {
            
            let values = details.stringValueOrArray(for: relationDetails)

            let objectOptions: [Relation.Object.Option] = values.compactMap { valueId in
                
                guard let objectDetail = storage.get(id: valueId) else {
                    if relationDetails.key == BundledRelationKey.setOf.rawValue {
                        return Relation.Object.Option(
                            id: valueId,
                            icon: .placeholder(nil),
                            title: Loc.deleted,
                            type: .empty,
                            isArchived: true,
                            isDeleted: true,
                            editorViewType: .page
                        )
                    }
                    return nil
                }
                        
                let name = objectDetail.title
                let icon: ObjectIconImage = {
                    if let objectIcon = objectDetail.objectIconImage {
                        return objectIcon
                    }
                    
                    return .placeholder(name.first)
                }()
                
                return Relation.Object.Option(
                    id: objectDetail.id,
                    icon: icon,
                    title: name,
                    type: objectDetail.objectType.name,
                    isArchived: objectDetail.isArchived,
                    isDeleted: objectDetail.isDeleted,
                    editorViewType: objectDetail.editorViewType
                )
            }
            
            return objectOptions
        }()
        
        return .object(
            Relation.Object(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                selectedObjects: objectOptions,
                limitedObjectTypes: relationDetails.objectTypes
            )
        )
    }
    
    func fileRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let fileOptions: [Relation.File.Option] = {
            let values = details.stringArrayValue(for: relationDetails.key)
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0)
            }

            let objectOptions: [Relation.File.Option] = objectDetails.map { objectDetail in
                let fileName: String = {
                    let name = objectDetail.name
                    let fileExt = objectDetail.fileExt
                    
                    guard fileExt.isNotEmpty
                    else { return name }
                    
                    return "\(name).\(fileExt)"
                }()
                
                let icon: ObjectIconImage = {
                    if let objectIconType = objectDetail.icon {
                        return .icon(objectIconType)
                    }
                    
                    let fileMimeType = objectDetail.fileMimeType
                    let fileName = objectDetail.name

                    guard fileMimeType.isNotEmpty, fileName.isNotEmpty else {
                        return .imageAsset(FileIconConstants.other)
                    }
                    
                    return .imageAsset(BlockFileIconBuilder.convert(mime: fileMimeType, fileName: fileName))
                }()
                
                return Relation.File.Option(
                    id: objectDetail.id,
                    icon: icon,
                    title: fileName
                )
            }
            
            return objectOptions
        }()
        
        return .file(
            Relation.File(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                files: fileOptions
            )
        )
    }
    
}

extension RelationFormat {
    
    var hint: String {
        switch self {
        case .longText:
            return Loc.enterText
        case .shortText:
            return Loc.enterText
        case .number:
            return Loc.enterNumber
        case .date:
            return Loc.enterDate
        case .url:
            return Loc.enterURL
        case .email:
            return Loc.enterEMail
        case .phone:
            return Loc.enterPhone
        case .status:
            return Loc.selectStatus
        case .tag:
            return Loc.selectTags
        case .file:
            return Loc.selectFiles
        case .object:
            return Loc.selectObjects
        case .checkbox:
            return ""
        case .unrecognized:
            return Loc.enterValue
        }
    }
    
}

private extension RelationDetails {
    
    func isFeatured(details: ObjectDetails) -> Bool {
        details.featuredRelations.contains(key)
    }
    
    func isEditable(objectLocked: Bool) -> Bool {
        guard !objectLocked else { return false }

        if key == BundledRelationKey.setOf.rawValue { return true }

        return !self.isReadOnlyValue
    }
}
