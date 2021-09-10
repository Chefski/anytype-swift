//
//  ObjectIconImageGuidelineSet.swift
//  ObjectIconImageGuidelineSet
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct ObjectIconImageGuidelineSet {
    
    let basicImageGuideline: ImageGuideline?
    let profileImageGuideline: ImageGuideline?
    let emojiImageGuideline: ImageGuideline?
    let todoImageGuideline: ImageGuideline?
    let placeholderImageGuideline: ImageGuideline?
    let staticImageGuideline: ImageGuideline?
    
    func imageGuideline(for iconImage: ObjectIconImage) -> ImageGuideline? {
        switch iconImage {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic:
                return basicImageGuideline
            case .profile:
                return profileImageGuideline
            case .emoji:
                return emojiImageGuideline
            }
        case .todo:
            return todoImageGuideline
        case .placeholder:
            return placeholderImageGuideline
        case .staticImage:
            return staticImageGuideline
        }
    }
    
}
