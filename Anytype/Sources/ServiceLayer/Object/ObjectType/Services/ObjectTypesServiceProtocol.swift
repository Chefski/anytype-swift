//
//  ObjectTypesServiceProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

public protocol ObjectTypesServiceProtocol: AnyObject {
    
    func obtainObjectTypes() -> Set<ObjectType>
    
}
