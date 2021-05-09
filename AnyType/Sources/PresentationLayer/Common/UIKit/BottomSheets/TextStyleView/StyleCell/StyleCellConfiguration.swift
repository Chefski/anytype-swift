//
//  StyleCellConfiguration.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


struct StyleCellBackgroundConfiguration {
    static func configuration(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.clear()
        background.cornerRadius = 10

        if state.isHighlighted || state.isSelected {
            // Set nil to use the inherited tint color of the cell when highlighted or selected
            background.backgroundColor = UIColor.grayscale10

            if state.isHighlighted {
                // Reduce the alpha of the tint color to 30% when highlighted
                background.backgroundColorTransformer = .init { $0.withAlphaComponent(0.3) }
            }
        }
        return background
    }
}

struct StyleCellContentConfiguration: UIContentConfiguration, Hashable {
    var text: String? = nil
    var font: UIFont? = nil

    func makeContentView() -> UIView & UIContentView {
        return StyleCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
