//
//  UnsupportedBlockContentConfiguration.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct UnsupportedBlockContentConfiguration {
    let text: String
    private(set) var currentConfigurationState: UICellConfigurationState?
}

extension UnsupportedBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        return UnsupportedBlockView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
