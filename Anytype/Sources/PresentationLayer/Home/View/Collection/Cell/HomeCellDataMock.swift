import UIKit

// TODO: add #if DEBUG
struct HomeCellDataMock {
    static let data = [
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .emoji(IconEmoji("📘")!),
            title: .default(title: "Ubik"),
            type: "Book",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: false
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .default(title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include"),
            type: "Page",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .default(title: "GridItem"),
            type: "Component",
            isLoading: true,
            isArchived: true,
            isDeleted: false,
            selected: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .emoji(IconEmoji("🤡")!),
            title: .todo(title: "DO IT!", isChecked: false),
            type: "Task",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: false
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .profile(.character("👽")),
            title: .default(title: "Neo"),
            type: "Character",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: false
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .todo(title: "Relax", isChecked: true),
            type: "Character",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: false
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .default(title: "Main"),
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: false
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .profile(.character("A")),
            title: .default(title: "Anton"),
            type: "Humanoid",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: true
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .todo(title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo", isChecked: true),
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            selected: false
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .todo(title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo", isChecked: true),
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: true,
            selected: false
        )
    ]
}
