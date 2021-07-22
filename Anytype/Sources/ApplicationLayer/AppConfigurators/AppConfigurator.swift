//
//  AppConfigurator.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class AppConfigurator {
    
    private let configurators: [AppConfiguratorProtocol] = [
        FirebaseService(),
        AnalyticsConfigurator(),
        KingfisherConfigurator()
    ]

    func configure() {
        configurators.forEach {
            $0.configure()
        }
    }
    
}
