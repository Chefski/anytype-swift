//
//  DocumentViewCell+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    enum DocumentViewCells {}
}

// MARK: - Options
extension Namespace.DocumentViewCells.Cell {
    struct Options {
        var useUIKit: Bool = true
        var shouldShowIndent: Bool = false
    }
}

// MARK: - Layout
extension Namespace.DocumentViewCells {
    struct Layout {
        var containedViewInset = 8
        var indentationWidth = 8
        var boundaryWidth = 2
        var zero = 0
    }
}

// MARK: - UITableView
extension Namespace.DocumentViewCells {
    class TableViewCell: UITableViewCell {
        /// Variables
        
        private let ourView: Cell = .init()
        
        /// Initialization
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        /// Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        func setupUIElements() {
            self.selectionStyle = .none
            self.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.ourView)
        }
        
        func addLayout() {
            let view = self.ourView
            
            if let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        /// OnLayoutSubviews
        override func layoutSubviews() {
            super.layoutSubviews()
            self.ourView.onFirstResponder()
        }
        
        /// Configurations
        func configured(_ model: Cell.Model) -> Self {
            _ = self.ourView.configured(model)
            return self
        }
        
        func configured(useUIKit: Bool) -> Self {
            _ = self.ourView.configured(useUIKit: useUIKit)
            return self
        }
        
        func configured(shouldShowIndent: Bool) -> Self {
            _ = self.ourView.configured(shouldShowIndent: shouldShowIndent)
            return self
        }
    }
    class CollectionViewCell: UICollectionViewCell {
        /// Variables
        private let ourView: Cell = .init()

        /// Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.ourView)
        }
        
        func addLayout() {
            let view = self.ourView
            
            if let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        /// OnLayoutSubviews
        override func layoutSubviews() {
            super.layoutSubviews()
            self.ourView.onFirstResponder()
        }
        
        /// Configurations
        func configured(_ model: Cell.Model) -> Self {
            _ = self.ourView.configured(model)
            return self
        }
        
        func configured(useUIKit: Bool) -> Self {
            _ = self.ourView.configured(useUIKit: useUIKit)
            return self
        }
        
        func configured(shouldShowIndent: Bool) -> Self {
            _ = self.ourView.configured(shouldShowIndent: shouldShowIndent)
            return self
        }
    }
}

// MARK: - Cell
extension Namespace.DocumentViewCells {
    class Cell: UIView {
        
        /// Aliases
        typealias Model = DocumentModule.DocumentViewModel.Row
        
        /// Variables
        /// Subscriptions
        var selectionSubscription: AnyCancellable?
        
        /// Model
        var model: Model?
        
        /// Views
        var contentView: UIView {
            self
        }
        var containedView: UIView?
        var containerView: UIView?
        var boundaryView: UIView?
        var elementsView: UIView? // top-most view
        
        /// Constraints
        var boundaryRevealConstraint: NSLayoutConstraint?
        var indentationConstraint: NSLayoutConstraint?
        
        /// Configurations
        var options: Options = .init()
        var layout: Layout = .init()
        
        /// Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: - Setup
        func setup() {
            self.translatesAutoresizingMaskIntoConstraints = false
            let containerView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            let boundaryView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .gray
                return view
            }()
            
            let elementsView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
                        
            elementsView.addSubview(containerView)
            elementsView.addSubview(boundaryView)
            
            self.contentView.addSubview(elementsView)
            
            self.containerView = containerView
            self.boundaryView = boundaryView
            self.elementsView = elementsView
            
            self.addLayout()
        }
        
        func addLayout() {
            
            if let view = self.elementsView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
                self.indentationConstraint = view.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
                self.indentationConstraint?.isActive = true
            }
            
            if let view = self.boundaryView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                ])
                self.boundaryRevealConstraint = view.widthAnchor.constraint(equalToConstant: 0)
                self.boundaryRevealConstraint?.isActive = true
            }
            
            if let view = self.containerView, let superview = view.superview, let leftView = self.boundaryView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
    }
}

// MARK: Configured
extension Namespace.DocumentViewCells.Cell {
    class ViewBuilder {
        
        class func createView(_ model: BlockViewBuilderProtocol?, useUIKit: Bool) -> UIView? {
            guard let model = model else { return nil }
            
            if useUIKit {
                let view = model.buildUIView()
                
                let superview = UIView()
                superview.translatesAutoresizingMaskIntoConstraints = false
                superview.addSubview(view)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
                
                return superview
            }
            let controller = UIHostingController(rootView: model.buildView())
            let view = controller.view
            return view
        }
    }
    
    private func updateIfNewModel(_ model: Model) {
        if model != self.model {
            /// Check that model has changed OR its Cached has changed
            
            if model.diffable() != self.model?.diffable() {
                self.model = model
                
                // put into container
                if let viewModel = self.model, let view = ViewBuilder.createView(viewModel.builder, useUIKit: self.options.useUIKit) {
                    self.containedView?.removeFromSuperview()
                    self.containedView = view
                    self.containerView?.addSubview(view)
                    print("thisView: \(view)")
                    
                    //TODO: Need to rething here for all blocks about insets
                    
                    let indentation = CGFloat(viewModel.indentationLevel + 1)
                    self.indentationConstraint?.constant = indentation * CGFloat(self.layout.indentationWidth)
                    
                    if let superview = view.superview {
                        view.translatesAutoresizingMaskIntoConstraints = false
                        let spacer: CGFloat = CGFloat(self.layout.containedViewInset)
                        NSLayoutConstraint.activate([
                            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: spacer),
                            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -spacer),
                            view.topAnchor.constraint(equalTo: superview.topAnchor, constant: spacer),
                            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -spacer)
                        ])
                        view.clipsToBounds = true
                    }
                }
                
                self.onSelectionStateChange()
            }
//            if !model.sameCachedDiffable(self.model) {
//                self.model?.update(cachedDiffable: model.cachedDiffable)
//                self.onSelectionStateChange()
//            }
        }
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.onFirstResponder()
//    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        self.model = nil
//        self.containedView?.removeFromSuperview()
//        self.containedView = nil
//    }
    
    func configured(_ model: Model) -> Self {
        self.updateIfNewModel(model)
        self.selectionSubscription = model.selectionCellEventPublisher.sink(receiveValue: { [weak self] (value) in
            self?.onSelectionStateChanged(value)
        })
        return self
    }
    
    func configured(useUIKit: Bool) -> Self {
        var options = self.options
        options.useUIKit = useUIKit
        self.update(options: options)
        return self
    }
    
    func configured(shouldShowIndent: Bool) -> Self {
        var options = self.options
        options.shouldShowIndent = shouldShowIndent
        self.update(options: options)
        return self
    }
}

// MARK: First responder support
extension Namespace.DocumentViewCells.Cell {
    func onFirstResponder() {
        if self.model?.isPendingFirstResponder == true {
            self.model?.resolvePendingFirstResponder()
        }
    }
}

// MARK: Selection support
extension Namespace.DocumentViewCells.Cell {
    func onSelectionStateChanged(_ value: DocumentModule.Selection.IncomingCellEvent) {
        let event = value
        switch event {
        case .unknown: return
        case let .payload(payload):
            let selectionDisabled = !payload.selectionEnabled
            
            let isSelected = payload.isSelected && payload.selectionEnabled
            
            self.contentView.backgroundColor = isSelected ? UIColor.lightGray.withAlphaComponent(0.6) : .clear
            self.contentView.layer.cornerRadius = isSelected ? 2.0 : 0.0
            
            self.contentView.isUserInteractionEnabled = selectionDisabled
        }
    }
    func onSelectionStateChange() {
        guard let event = self.model?.selectionCellEvent else {            
            return
        }
        self.onSelectionStateChanged(event)
    }
}

// MARK: Toggle
extension Namespace.DocumentViewCells.Cell {
    func update(options: Options) {
        if self.options.shouldShowIndent != options.shouldShowIndent {
            self.boundaryRevealConstraint?.constant = options.shouldShowIndent ? CGFloat(self.layout.boundaryWidth) : 0
            self.layoutIfNeeded()
        }
        
        self.options = options
    }
}

// MARK: - New Cells
// MARK: ContentConfigurations
extension Namespace.DocumentViewCells {
    enum ContentConfigurations {
        class Table: UITableViewCell {
            enum Event {
                case shouldLayoutSubviews
            }
            private var eventSubject: PassthroughSubject<Event, Never> = .init()
            var eventPublisher: AnyPublisher<Event, Never> = .empty()
            /// Initialization
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                self.setup()
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
                self.setup()
            }
            
            func setup() {
                self.selectionStyle = .none
                self.eventPublisher = self.eventSubject.eraseToAnyPublisher()
            }
            
            override func layoutSubviews() {
                // subscribe on events by view (?)
                super.layoutSubviews()
                self.eventSubject.send(.shouldLayoutSubviews)
            }
        }
    }
}

// MARK: Protocols
protocol DocumentModuleDocumentViewCellContentConfigurationsCellsListenerProtocol {
    func configure(publisher: AnyPublisher<DocumentModule.DocumentViewCells.ContentConfigurations.Table.Event, Never>)
}

fileprivate typealias ContentConfigurationsCells = Namespace.DocumentViewCells.ContentConfigurations

// MARK: ContentConfigurations
extension ContentConfigurationsCells {
    enum Text {}
    enum File {}
    enum Bookmark {}
    enum Other {}
    enum Link {}
    enum Unknown {}
}

// MARK: ContentConfigurations / Text
extension ContentConfigurationsCells.Text {
    enum Text {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {
            override func layoutSubviews() {
                if let view = self.contentView as? DocumentModuleDocumentViewCellContentConfigurationsCellsListenerProtocol {
                    view.configure(publisher: self.eventPublisher)
                }
                super.layoutSubviews()
            }
        }
        class Collection: UICollectionViewCell {}
    }
}

// MARK: ContentConfigurations / Files
extension ContentConfigurationsCells.File {
    enum File {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {}
        class Collection: UICollectionViewCell {}
    }
    enum Image {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {}
        class Collection: UICollectionViewCell {}
    }
}

// MARK: ContentConfigurations / Bookmark
extension ContentConfigurationsCells.Bookmark {
    enum Bookmark {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {}
        class Collection: UICollectionViewCell {}
    }
}

// MARK: ContentConfigurations / Divider
extension ContentConfigurationsCells.Other {
    enum Divider {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {}
        class Collection: UICollectionViewCell {}
    }
}

// MARK: ContentConfigurations / Link
extension ContentConfigurationsCells.Link {
    enum PageLink {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {}
        class Collection: UICollectionViewCell {}
    }
}

// MARK: ContentConfigurations / Unknown
extension ContentConfigurationsCells.Unknown {
    enum Label {
        class Table: DocumentModule.DocumentViewCells.ContentConfigurations.Table {}
        class Collection: UICollectionViewCell {}
    }
}
