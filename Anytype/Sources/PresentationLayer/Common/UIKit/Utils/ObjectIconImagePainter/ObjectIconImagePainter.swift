import Foundation
import UIKit

final class ObjectIconImagePainter {
    
    static let shared = ObjectIconImagePainter()
    
    private let imageStorage: ImageStorageProtocol = ImageStorage.shared
       
}

extension ObjectIconImagePainter: ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline) -> UIImage {
        let hash = "todo.\(isChecked).\(imageGuideline.identifier)"
        let image = isChecked ? UIImage.ObjectIcon.checkmark : UIImage.ObjectIcon.checkbox
        return draw(hash: hash, image: image, imageGuideline: imageGuideline, resize: true)
    }
    
    func staticImage(name: String, imageGuideline: ImageGuideline) -> UIImage {
        let hash = "staticImage.\(name).\(imageGuideline.identifier)"
        let image = UIImage.createImage(name)
        return draw(hash: hash, image: image, imageGuideline: imageGuideline, resize: false)
    }
    
    private func draw(hash: String, image: UIImage, imageGuideline: ImageGuideline, resize: Bool) -> UIImage {
        if let image = imageStorage.image(forKey: hash) {
            return image
        }
        
        let image = resize ? image.scaled(to: imageGuideline.size) : image
        let modifiedImage = image
            .rounded(
                radius: imageGuideline.cornersGuideline.radius,
                backgroundColor: UIColor.grayscale10.cgColor
            )
        
        imageStorage.saveImage(modifiedImage, forKey: hash)
        
        return modifiedImage
    }
    
    func image(with string: String,
               font: UIFont,
               textColor: UIColor,
               imageGuideline: ImageGuideline,
               backgroundColor: UIColor) -> UIImage {
        ImageBuilder(imageGuideline)
            .setText(string)
            .setFont(font)
            .setTextColor(textColor)
            .setImageColor(backgroundColor)
            .build()
    }
    
}
