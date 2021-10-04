//
//  ObjectHeaderCoverView.swift
//  ObjectHeaderCoverView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ObjectHeaderCoverView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()
    private let imageView = UIImageView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - ConfigurableView

extension ObjectHeaderCoverView: ConfigurableView {
    
    struct Model {
        let objectCover: ObjectHeaderCoverType
        let size: CGSize
    }
    
    func configure(model: Model) {
        switch model.objectCover {
        case let .cover(cover):
            configureCoverState(cover, model.size)
        case let .preview(image):
            configurePreviewState(image)
        }
    }
    
}

private extension ObjectHeaderCoverView {
    
    func configureCoverState(_ cover: DocumentCover, _ size: CGSize) {
        activityIndicatorView.hide()
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId, size)
        case let .color(color):
            showColor(color, size)
        case let .gradient(gradientColor):
            showGradient(gradientColor, size)
        }
    }
    
    private func showImageWithId(_ imageId: String, _ size: CGSize) {
        let imageGuideline = ImageGuideline(size: size)
        
        let placeholder = ImageBuilder(imageGuideline).build()
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: nil
        ).processor
        
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(
            with: ImageID(id: imageId, width: imageGuideline.size.width.asImageWidth).resolvedUrl,
            placeholder: placeholder,
            options: [.processor(processor)]
        )
        
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showColor(_ color: UIColor, _ size: CGSize) {
        let imageGuideline = ImageGuideline(size: size)
        
        imageView.image = ImageBuilder(imageGuideline)
            .setImageColor(color)
            .build()
        
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showGradient(_ gradient: GradientColor, _ size: CGSize) {
        imageView.image = GradientImageBuilder().image(
            size: size,
            color: gradient,
            point: GradientPoint(
                start: CGPoint(x: 0.5, y: 0),
                end: CGPoint(x: 0.5, y: 1)
            )
        )
        imageView.contentMode = .scaleToFill
    }
    
    private func configurePreviewState(_ image: UIImage?) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        activityIndicatorView.show()
    }
    
}

// MARK: - Private extension

private extension ObjectHeaderCoverView {
    
    func setupView() {
        setupBackgroundColor()
        
        imageView.clipsToBounds = true
        
        setupLayout()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .backgroundPrimary
        imageView.backgroundColor = .backgroundPrimary
    }
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview()
        }
        
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}
