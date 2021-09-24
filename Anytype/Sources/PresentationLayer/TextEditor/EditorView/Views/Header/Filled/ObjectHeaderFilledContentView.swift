//
//  ObjectHeaderFilledContentView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Combine

final class ObjectHeaderFilledContentView: UIView, UIContentView {
        
    // MARK: - Views
        
    private let headerView = ObjectHeaderView()
    
    // MARK: - Private variables
    
    private var subscription: AnyCancellable?
    private var appliedConfiguration: ObjectHeaderFilledConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? ObjectHeaderFilledConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderFilledConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration)
        
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .editorCollectionContentOffsetChangeNotification,
            object: nil
        )
            .compactMap { $0.object as? CGFloat }
            .receiveOnMain()
            .sink { self.updateCoverTransform($0) }
    }
    
    deinit {
        subscription = nil
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ObjectHeaderFilledContentView  {
    
    func setupLayout() {
        addSubview(headerView) {
            $0.pinToSuperview()
        }
    }
    
    func apply(_ configuration: ObjectHeaderFilledConfiguration) {
        appliedConfiguration = configuration
        headerView.configure(
            model: ObjectHeaderView.Model(
                state: configuration.state,
                width: configuration.width
            )
        )
    }
    
    func updateCoverTransform(_ offset: CGFloat) {
        guard offset.isLess(than: CGFloat.zero) else {
            headerView.applyCoverTransform(.identity)
            return
        }
        
        let coverHeight = ObjectHeaderView.Constants.coverHeight
        let scaleY = (abs(offset) + coverHeight) / coverHeight
        let scaledCoverHeight = coverHeight * scaleY

        var t = CGAffineTransform.identity
                
        t = t.translatedBy(
            x: 0,
            y: -((scaledCoverHeight - coverHeight) * 0.5)
        )
        
        t = t.scaledBy(x: scaleY, y: scaleY)
        
        headerView.applyCoverTransform(t)
    }
    
}
