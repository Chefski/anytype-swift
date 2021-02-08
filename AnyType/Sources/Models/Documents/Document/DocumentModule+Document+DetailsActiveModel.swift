//
//  DocumentModule+Document+DetailsActiveModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import os
import BlocksModels

fileprivate typealias Namespace = DocumentModule.Document
fileprivate typealias FileNamespace = DocumentModule.Document.DetailsActiveModel

private extension Logging.Categories {
    static let detailsActiveModel: Self = "DocumentModule.Document.DetailsActiveModel"
}

/// TODO: Rethink API.
/// It is too complex now.
extension Namespace {
    // Sends and receives data via serivce.
    class DetailsActiveModel {
        typealias PageDetails = DetailsInformationModelProtocol
        typealias Builder = TopLevel.Builder
        typealias Details = TopLevel.AliasesMap.DetailsContent
        typealias Events = EventListening.PackOfEvents
        private var documentId: String?
        
        /// TODO:
        /// Add DI later.
        private var service: ServiceLayerModule.SmartBlockActionsService = .init()
        
        // MARK: Publishers
        @Published private(set) var currentDetails: PageDetails = TopLevel.Builder.detailsBuilder.informationBuilder.empty()
        private(set) var wholeDetailsPublisher: AnyPublisher<PageDetails, Never> = .empty() {
            didSet {
                self.currentDetailsSubscription = self.wholeDetailsPublisher.sink { [weak self] (value) in
                    self?.currentDetails = value
                }
            }
        }
        var currentDetailsSubscription: AnyCancellable?
        private var eventSubject: PassthroughSubject<Events, Never> = .init()
    }
}

// MARK: Configuration
extension FileNamespace {
    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }
    
    func configured(publisher: AnyPublisher<PageDetails, Never>) {
        self.wholeDetailsPublisher = publisher
    }
    
    func configured(eventSubject: PassthroughSubject<Events, Never>) {
        self.eventSubject = eventSubject
    }
}

// MARK: Handle Events
extension FileNamespace {
    private func handle(events: Events) {
        self.eventSubject.send(events)
    }
}

// MARK: Updates
extension FileNamespace {
    private enum UpdateScheduler {
        static let defaultTimeInterval: RunLoop.SchedulerTimeType.Stride = 5.0
    }
    
    /// Maybe add AnyPublisher as Return result?
    func update(details: Details) -> AnyPublisher<Void, Error>? {
        guard let documentId = self.documentId else {
            let logger = Logging.createLogger(category: .detailsActiveModel)
            os_log(.debug, log: logger, "update(details:). Our document is not ready yet")
            return nil
        }
        
        return self.service.setDetails.action(contextID: documentId, details: BlocksModelsModule.Parser.Details.Converter.asMiddleware(models: [details])).handleEvents(receiveOutput: { [weak self] (value) in
            self?.handle(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
        }).successToVoid().eraseToAnyPublisher()
    }
}
