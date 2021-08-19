//
//  EditorNavigationBarHelper.swift
//  EditorNavigationBarHelper
//
//  Created by Konstantin Mordan on 18.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels

final class EditorNavigationBarHelper {
    
    let onBackBarButtonItemTap: () -> Void
    let onSettingsBarButtonItemTap: () -> Void
    
    private let navigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private lazy var backBarButtonItemView = EditorBarButtonItemView(
        image: .backArrow,
        action: onBackBarButtonItemTap
    )
    
    private lazy var settingsBarButtonItemView = EditorBarButtonItemView(
        image: .more,
        action: onSettingsBarButtonItemTap
    )
    
    private var isBarButtonItemsWithBackground = false
    private var isTitleViewHidden = true
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var objectHeaderHeight: CGFloat = 0.0
    
    init(onBackBarButtonItemTap: @escaping () -> Void, onSettingsBarButtonItemTap: @escaping () -> Void) {
        self.onBackBarButtonItemTap = onBackBarButtonItemTap
        self.onSettingsBarButtonItemTap = onSettingsBarButtonItemTap
        
        navigationBarBackgroundView.backgroundColor = .grayscaleWhite
        navigationBarBackgroundView.alpha = 0.0
    }
    
}

extension EditorNavigationBarHelper {
    
    func handleViewWillAppear(_ vc: UIViewController?, _ scrollView: UIScrollView) {
        guard let vc = vc else {
            return
        }
        
        configureNavigationItem(in: vc)
        
        contentOffsetObservation = scrollView.observe(
            \.contentOffset,
            options: .new
        ) { [weak self] scrollView, _ in
            self?.handleScrollViewOffsetChange(scrollView.contentOffset.y)
        }
    }
    
    func handleViewWillDisappear() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    func configureNavigationBarUsing(header: ObjectHeader, titleBlockText: BlockText?) {
        objectHeaderHeight = header.height
        
        isBarButtonItemsWithBackground = header.isWithCover
        updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
        
        let title: String = {
            guard
                let string = titleBlockText?.attributedText.string,
                !string.isEmpty
            else {
                return "Untitled".localized
            }
            
            return string
        }()
        
        navigationBarTitleView.configure(
            model: EditorNavigationBarTitleView.Model(
                icon: nil,
                title: title
            )
        )
        
    }
    
    func addNavigationBarBackgroundView(to view: UIView) {
        view.addSubview(navigationBarBackgroundView) {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.bottom.equal(to: view.layoutMarginsGuide.topAnchor)
        }
    }
    
}

private extension EditorNavigationBarHelper {
    
    func configureNavigationItem(in vc: UIViewController) {
        navigationBarTitleView.isHidden = isTitleViewHidden
        vc.navigationItem.titleView = navigationBarTitleView
        
        vc.setupBackBarButtonItem(
            UIBarButtonItem(customView: backBarButtonItemView)
        )
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: settingsBarButtonItemView
        )
        
        updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
    }
    
    func updateBarButtonItemsBackground(hasBackground: Bool) {
        [backBarButtonItemView, settingsBarButtonItemView].forEach {
            guard $0.hasBackground != hasBackground else { return }
            
            $0.hasBackground = hasBackground
        }
    }
    
    func handleScrollViewOffsetChange(_ newOffset: CGFloat) {
        let startAppearingOffset = objectHeaderHeight - 50
        let endAppearingOffset = objectHeaderHeight

        let navigationBarHeight = navigationBarBackgroundView.bounds.height
        
        let yFullOffset = newOffset + navigationBarHeight

        let alpha: CGFloat? = {
            if yFullOffset < startAppearingOffset {
                return 0
            } else if yFullOffset > endAppearingOffset {
                return 1
            } else if yFullOffset > startAppearingOffset, yFullOffset < endAppearingOffset {
                let currentDiff = yFullOffset - startAppearingOffset
                let max = endAppearingOffset - startAppearingOffset
                return currentDiff / max
            }
            
            return nil
        }()
        
        guard let alpha = alpha else {
            return
        }
        
        switch alpha {
        case 0.0:
            isTitleViewHidden = true
            navigationBarTitleView.isHidden = isTitleViewHidden
            updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
        case 1.0:
            isTitleViewHidden = false
            navigationBarTitleView.isHidden = isTitleViewHidden
            updateBarButtonItemsBackground(hasBackground: false)
        default:
            break
        }

        navigationBarBackgroundView.alpha = alpha
    }
    
}

private extension ObjectHeader {
    
    var isWithCover: Bool {
        switch self {
        case .iconOnly:
            return false
        case .coverOnly:
            return true
        case .iconAndCover:
            return true
        case .empty:
            return false
        }
    }
    
    var height: CGFloat {
        switch self {
        case .iconOnly:
            return ObjectHeaderIconOnlyContentView.Constants.height
        case .coverOnly:
            return ObjectHeaderCoverOnlyContentView.Constants.height
        case .iconAndCover:
            return ObjectHeaderIconAndCoverContentView.Constants.height
        case .empty:
            return ObjectHeaderEmptyContentView.Constants.height
        }
    }
    
}
