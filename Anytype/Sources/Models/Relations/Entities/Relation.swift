import Foundation
import BlocksModels

enum Relation: Hashable, Identifiable {
    case text(Text)
    case number(Text)
    case status(Status)
    case date(Date)
    case object(Object)
    case checkbox(Checkbox)
    case url(Text)
    case email(Text)
    case phone(Text)
    case tag(Tag)
    case unknown(Unknown)
}

// MARK: - RelationProtocol

extension Relation: RelationProtocol {
    
    var id: String {
        switch self {
        case .text(let text): return text.id
        case .number(let text): return text.id
        case .status(let status): return status.id
        case .date(let date): return date.id
        case .object(let object): return object.id
        case .checkbox(let checkbox): return checkbox.id
        case .url(let text): return text.id
        case .email(let text): return text.id
        case .phone(let text): return text.id
        case .tag(let tag): return tag.id
        case .unknown(let unknown): return unknown.id
        }
    }
    
    var name: String {
        switch self {
        case .text(let text): return text.name
        case .number(let text): return text.name
        case .status(let status): return status.name
        case .date(let date): return date.name
        case .object(let object): return object.name
        case .checkbox(let checkbox): return checkbox.name
        case .url(let text): return text.name
        case .email(let text): return text.name
        case .phone(let text): return text.name
        case .tag(let tag): return tag.name
        case .unknown(let unknown): return unknown.name
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .text(let text): return text.isEditable
        case .number(let text): return text.isEditable
        case .status(let status): return status.isEditable
        case .date(let date): return date.isEditable
        case .object(let object): return object.isEditable
        case .checkbox(let checkbox): return checkbox.isEditable
        case .url(let text): return text.isEditable
        case .email(let text): return text.isEditable
        case .phone(let text): return text.isEditable
        case .tag(let tag): return tag.isEditable
        case .unknown(let unknown): return unknown.isEditable
        }
    }
    
    var isFeatured: Bool {
        switch self {
        case .text(let text): return text.isFeatured
        case .number(let text): return text.isFeatured
        case .status(let status): return status.isFeatured
        case .date(let date): return date.isFeatured
        case .object(let object): return object.isFeatured
        case .checkbox(let checkbox): return checkbox.isFeatured
        case .url(let text): return text.isFeatured
        case .email(let text): return text.isFeatured
        case .phone(let text): return text.isFeatured
        case .tag(let tag): return tag.isFeatured
        case .unknown(let unknown): return unknown.isFeatured
        }
    }
    
}

// MARK: - hint

extension Relation {
    
    var hint: String {
        switch self {
        case .text: return "Enter text".localized
        case .number: return "Enter number".localized
        case .date: return "Enter date".localized
        case .object: return "Select objects".localized
        case .url: return "Enter URL".localized
        case .email: return "Enter e-mail".localized
        case .phone: return "Enter phone".localized
        case .status: return "Select status".localized
        case .tag: return "Select tags".localized
        case .checkbox: return ""
        case .unknown: return "Enter value".localized
        }
    }
    
}
