//
//  ObjectHeaderEmptyConfiguration.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderEmptyConfiguration: UIContentConfiguration, Hashable {
    let data: ObjectHeaderEmptyData
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderEmptyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
