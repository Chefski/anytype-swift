import Foundation
import AnytypeCore

protocol EditorBottomNavigationManagerProtocol: AnyObject {
    func multiselectActive(_ active: Bool)
    func onScroll(bottom: Bool)
    func styleViewActive(_ active: Bool)
}

final class EditorBottomNavigationManager: EditorBottomNavigationManagerProtocol {
    
    // MARK: - DI
    
    private weak var browser: EditorBrowser?
    
    // MARK: - State
    
    private var isMultiselectActive = false
    private var scrollDirectionBottom = false
    private var isStyleViewActive = false
    
    init(browser: EditorBrowser?) {
        self.browser = browser
    }
    
    // MARK: -
    
    func multiselectActive(_ active: Bool) {
        isMultiselectActive = active
        updateNavigationVisibility(animated: false)
    }

    func onScroll(bottom: Bool) {
        guard !isMultiselectActive, scrollDirectionBottom != bottom else { return }
        scrollDirectionBottom = bottom
        updateNavigationVisibility(animated: true)
    }
    
    func styleViewActive(_ active: Bool) {
        isStyleViewActive = active
        updateNavigationVisibility(animated: false)
    }
    
    private func updateNavigationVisibility(animated: Bool) {
        if isMultiselectActive {
            browser?.setNavigationViewHidden(true, animated: animated)
            return
        }
        
        if isStyleViewActive {
            browser?.setNavigationViewHidden(true, animated: animated)
            return
        }

        if scrollDirectionBottom {
            browser?.setNavigationViewHidden(true, animated: animated)
        } else {
            browser?.setNavigationViewHidden(false, animated: animated)
        }
    }
}