//
//  FeaturedRelationsBlockViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 25.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels

// TODO: Check if block updates when featuredRelations is changed
struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    let indentationLevel: Int = 0
    let information: BlockInformation
    let type: String
    let onTypeTap: () -> Void
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            type
        ] as [AnyHashable]
    }
    
    init(
        information: BlockInformation,
        type: String,
        onTypeTap: @escaping () -> Void
    ) {
        self.information = information
        self.type = type
        self.onTypeTap = onTypeTap
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        FeaturedRelationsBlockContentConfiguration(
            type: type,
            alignment: information.alignment.asNSTextAlignment
        )
    }
    
    func didSelectRowInTableView() {
        onTypeTap()
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        []
    }
    
    func handle(action: ContextualMenu) {}
    
}
