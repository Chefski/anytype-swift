//
//  GradientImageBuilder.swift
//  GradientImageBuilder
//
//  Created by Konstantin Mordan on 28.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//


import Foundation
import UIKit

final class GradientImageBuilder {

    // MARK: - Private variables
    
    private let imageStorage: ImageStorageProtocol = ImageStorage.shared
    
    // MARK: - Public func

    func image(size: CGSize, color: GradientColor, point: GradientPoint) -> UIImage {
        let key = """
        \(GradientImageBuilder.self).
        \(size).
        \(color.identifier).
        \(point.identifier)
        """
        
        if let cachedImage = imageStorage.image(forKey: key) {
            return cachedImage
        }

        let image = UIImage.gradient(
            size: size,
            startColor: color.start,
            endColor: color.end,
            startPoint: point.start,
            endPoint: point.end
        )
        
        imageStorage.saveImage(image, forKey: key)
        
        return image
    }
    
}
