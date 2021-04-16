import Foundation
import Combine
import BlocksModels

fileprivate typealias Namespace = EditorModule.Selection

extension Namespace.Handler {
    struct Storage {
        typealias Id = BlockId
        typealias Ids = Set<Id>
        /// Selected ids that user has selected.
        private var selectedIds: Ids = .init()
        
        /// Flag that determines if user initiates selection mode.
        private var isSelectionEnabled: Bool = false {
            didSet {
                if !self.isSelectionEnabled {
                    self.clear()
                }
            }
        }
        
        // MARK: Selection
        func selectionEnabled() -> Bool { self.isSelectionEnabled }
        mutating func toggleSelectionEnabled() { self.isSelectionEnabled.toggle() }
        mutating func startSelection() { self.isSelectionEnabled = true }
        mutating func stopSelection() { self.isSelectionEnabled = false }
        
        // MARK: Ids
        func isEmpty() -> Bool { self.selectedIds.isEmpty }
        func count() -> Int { self.selectedIds.count }
        func listSelectedIds() -> [Id] { .init(self.selectedIds) }
        func contains(id: Id) -> Bool { self.selectedIds.contains(id) }
        mutating func set(ids: Ids) { self.selectedIds = ids }
        mutating func clear() { self.selectedIds = .init() }
        mutating func toggle(id: Id) { self.selectedIds.contains(id) ? self.remove(id: id) : self.add(id: id) }
        mutating func add(id: Id) { self.selectedIds.insert(id) }
        mutating func remove(id: Id) { self.selectedIds.remove(id) }
        
        mutating func add(ids: Set<Id>) { self.selectedIds = self.selectedIds.union(ids) }
        mutating func remove(ids: Set<Id>) { self.selectedIds = self.selectedIds.subtracting(ids) }
    }
}

extension Namespace {
    class Handler {
        typealias SelectionEvent = EditorModule.Selection.IncomingEvent
        /// Publishers
        private var subscription: AnyCancellable?
        private var storageEventsSubject: PassthroughSubject<SelectionEvent, Never> = .init()
        private var storageEventsPublisher: AnyPublisher<SelectionEvent, Never> = .empty()
        private lazy var turnIntoOptionsStorage = TurnIntoSelectionStorage()
        /// Storage
        private var storage: Storage = .init() {
            didSet {
                self.storageDidChangeSubject.send(self.storage)
                self.handle(self.storage)
            }
        }
        
        private var storageDidChangeSubject: PassthroughSubject<Storage, Never> = .init()
        private var storageDidChangePublisher: AnyPublisher<Storage, Never> = .empty()
        
        /// Updates
        private func storageEvent(from storage: Storage) -> SelectionEvent {
            if !storage.selectionEnabled() {
                return .selectionDisabled
            }
            if storage.isEmpty() {
                return .selectionEnabled
            }

            let typesArray = self.turnIntoOptionsStorage.turnIntoOptions()
            return .selectionEnabled(.nonEmpty(.init(storage.count()),
                                               turnIntoStyles: typesArray))
        }
        
        private func handle(_ storageUpdate: Storage) {
            self.storageEventsSubject.send(self.storageEvent(from: storageUpdate))
        }
        
        /// Setup
        func setup() {
            self.storageDidChangePublisher = self.storageDidChangeSubject.eraseToAnyPublisher()
            self.storageEventsPublisher = self.storageEventsSubject.eraseToAnyPublisher()
        }
        
        // MARK: - Initialization
        init() {
            self.setup()
        }
    }
}

extension Namespace {
    enum IncomingCellEvent: Equatable {
        static func == (lhs: EditorModule.Selection.IncomingCellEvent, rhs: EditorModule.Selection.IncomingCellEvent) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown): return true
            case let (.payload(left), .payload(right)): return left.selectionEnabled == right.selectionEnabled && left.isSelected == right.isSelected
            default: return false
            }
        }
        
        struct Payload {
            var selectionEnabled: Bool
            var isSelected: Bool
        }
        case unknown
        case payload(Payload)
    }
    enum IncomingEvent {
        enum CountEvent {
            static var `default`: Self = .isEmpty
            case isEmpty
            case nonEmpty(UInt, turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes])
            static func from(_ value: Int, turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes]) -> Self {
                value <= 0 ? .isEmpty : nonEmpty(.init(value), turnIntoStyles: turnIntoStyles)
            }
        }
        case selectionDisabled
        case selectionEnabled(CountEvent)
        static var selectionEnabled: Self = .selectionEnabled(.default)
    }
}

extension Namespace.Handler: EditorModuleSelectionHandlerProtocol {
    func selectionEnabled() -> Bool {
        self.storage.selectionEnabled()
    }
    
    func set(selectionEnabled: Bool) {
        if self.storage.selectionEnabled() != selectionEnabled {
            self.storage.toggleSelectionEnabled()
        }
        if !selectionEnabled {
            self.turnIntoOptionsStorage.clear()
        }
    }
    
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    func deselect(ids: [BlockId: BlockContentType]) {
        guard self.selectionEnabled() else { return }
        ids.values.forEach { self.turnIntoOptionsStorage.deselectBlockType(type: $0) }
        self.storage.remove(ids: Set(ids.keys))
    }
        
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    /// Is it better to use `add(ids:)` here?
    ///
    func select(ids: [BlockId: BlockContentType]) {
        guard self.selectionEnabled() else { return }
        ids.values.forEach { self.turnIntoOptionsStorage.selectBlockType(type: $0) }
        self.storage.set(ids: Set(ids.keys))
    }
    
    func list() -> [BlockId] {
        self.storage.listSelectedIds()
    }
    
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    /// But, we still `CAN` clear storage without checking if selection is enabled.
    ///
    func clear() {
        self.turnIntoOptionsStorage.clear()
        self.storage.clear()
    }
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never> {
        self.storageEventsPublisher
    }
    
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    func set(selected: Bool, id: BlockId, type: BlockContentType) {
        guard self.selectionEnabled() else { return }
        if selected {
            self.turnIntoOptionsStorage.selectBlockType(type: type)
        } else {
            self.turnIntoOptionsStorage.deselectBlockType(type: type)
        }
        let contains = self.storage.contains(id: id)
        if contains != selected {
            self.storage.toggle(id: id)
        }
    }
    
    func selected(id: BlockId) -> Bool {
        self.storage.contains(id: id)
    }
    
    func selectionCellEvent(_ id: BlockId) -> EditorModule.Selection.IncomingCellEvent {
        let isSelected = self.selected(id: id)
        return .payload(.init(selectionEnabled: self.selectionEnabled(), isSelected: isSelected))
    }
    
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorModule.Selection.IncomingCellEvent, Never> {
        self.storageDidChangePublisher.map({ value in
            .payload(.init(selectionEnabled: value.selectionEnabled(), isSelected: value.contains(id: id)))
        }).removeDuplicates().eraseToAnyPublisher()
    }
}

extension EditorModule.Document.ViewController.ViewModel: EditorModuleSelectionHandlerHolderProtocol {
    func selectAll() {
        let ids = self.builders.dropFirst().reduce(into: [BlockId: BlockContentType]()) { result, model in
            result[model.blockId] = model.getBlock().blockModel.information.content.type
        }
        self.select(ids: ids)
    }
}
