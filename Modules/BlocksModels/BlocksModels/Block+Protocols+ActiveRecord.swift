//
//  Block+Protocols+ActiveRecord.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine

// MARK: - BlockActiveRecord / BlockModel
public protocol BlockActiveRecordHasContainerProtocol {
    var container: BlockContainerModelProtocol? {get}
}

// MARK: - BlockActiveRecord / BlockModel
public protocol BlockActiveRecordHasBlockModelProtocol {
    var blockModel: BlockModelProtocol {get}
}

// MARK: - BlockActiveRecord / IndentationLevel
public protocol BlockActiveRecordHasIndentationLevelProtocol {
    static var defaultIndentationLevel: Int {get}
    var indentationLevel: Int {get}
}

// MARK: - BlockActiveRecord / isRoot
public protocol BlockActiveRecordCanBeRootProtocol {
    var isRoot: Bool {get}
}

// MARK: - BlockActiveRecord / FindRoot and FindParent
public protocol BlockActiveRecordFindParentAndRootProtocol {
    func findParent() -> Self?
    func findRoot() -> Self?
}

// MARK: - BlockActiveRecord / Children
public protocol BlockActiveRecordFindChildProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func childrenIds() -> [BlockId]
    func findChild(by id: BlockId) -> Self?
}

// MARK: - BlockActiveRecord / isFirstRepsonder
public protocol BlockActiveRecordCanBeFirstResponserProtocol {
    var isFirstResponder: Bool {get set}
    func unsetFirstResponder()
}

// MARK: - BlockActiveRecord / isToggled
public protocol BlockActiveRecordCanBeToggledProtocol {
    var isToggled: Bool {get set}
}

// MARK: - BlockActiveRecord / FocusAt
public protocol BlockActiveRecordCanHaveFocusAtProtocol {
    typealias Position = TopLevel.AliasesMap.FocusPosition
    var focusAt: Position? {get set}
}

public extension BlockActiveRecordCanHaveFocusAtProtocol {
    mutating func unsetFocusAt() { self.focusAt = nil }
}

// MARK: - BlockActiveRecord / Publishing
public protocol BlockHasDidChangePublisherProtocol {
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
}
