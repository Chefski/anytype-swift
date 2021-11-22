//
//  DetailsServiceProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 22.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import SwiftProtobuf

protocol DetailsServiceProtocol {
        
    func updateRelationValue(key: String, value: Google_Protobuf_Value)

    func updateBundledDetails(_ bundledDpdates: [BundledDetails])
    func updateDetails(_ updates: [DetailsUpdate])
    func setLayout(_ detailsLayout: DetailsLayout)
    
}
