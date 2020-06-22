//
//  ServiceLayerModule.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

enum ServiceLayerModule {
    struct Success {
        var contextID: String
        var messages: [Anytype_Event.Message]
        init(_ value: Anytype_ResponseEvent) {
            self.contextID = value.contextID
            self.messages = value.messages
        }
    }
}
