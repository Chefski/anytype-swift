//
//  DashboardService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

class DashboardService: DashboardServiceProtocol {
    private let middleConfigService = MiddleConfigService()
    
    func subscribeDashboardEvents() -> AnyPublisher<Never, Error> {
        middleConfigService.obtainConfig()
            .flatMap { config in
                Anytype_Rpc.Block.Open.Service.invoke(contextID: config.homeBlockID, blockID: config.homeBlockID, breadcrumbsIds: [])
                    .subscribe(on: DispatchQueue.global())
        }
        .ignoreOutput()
        .eraseToAnyPublisher()
    }
    
    func obtainDashboardBlocks() -> AnyPublisher<Anytype_Event.Block.Show, Never> {
        NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
        .compactMap { notification in
            return notification.object as? Anytype_Event
        }
        .map { $0.messages }
        .compactMap {
            $0.first { message in
                guard let value = message.value else { return false }
                
                if case Anytype_Event.Message.OneOf_Value.blockShow = value {
                    return true
                }
                return false
            }?.blockShow
        }
        .eraseToAnyPublisher()
    }
}
