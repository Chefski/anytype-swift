import Foundation
import SwiftUI
import AnytypeCore

// Needs refactoring - https://linear.app/anytype/issue/IOS-978

struct SwiftUIObjectIconImageView: View {
    
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
    init(iconImage: ObjectIconImage, usecase: ObjectIconImageUsecase) {
        self.iconImage = iconImage
        self.usecase = usecase
    }
    
    var body: some View {
        if FeatureFlags.newObjectIcon {
            IconView(icon: iconImage)
        } else {
            LegacySwiftUIObjectIconImageView(iconImage: iconImage, usecase: usecase)
        }
    }
}

struct LegacySwiftUIObjectIconImageView: View {
    
    @ObservedObject private var model = SwiftUIObjectIconImageViewModel()
    
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
    init(iconImage: ObjectIconImage, usecase: ObjectIconImageUsecase) {
        self.iconImage = iconImage
        self.usecase = usecase
        
        model.update(iconImage: iconImage, usecase: usecase)
    }
    
    var body: some View {
        Image(uiImage: model.image)
    }
}

final class SwiftUIObjectIconImageViewModel: ObservableObject {
    
    @Published var image = UIImage()

    private let uiView = ObjectIconImageViewLegacy()
    private var observation: NSKeyValueObservation?
    
    init() {
        observation = uiView.imageView.observe(\.image, changeHandler: { [weak self] view, _ in
            self?.image = view.image ?? UIImage()
        })
    }
    
    func update(iconImage: ObjectIconImage, usecase: ObjectIconImageUsecase) {
        uiView.configure(
            model: ObjectIconImageViewLegacy.Model(
                iconImage: iconImage,
                usecase: usecase
            )
        )
    }
}
