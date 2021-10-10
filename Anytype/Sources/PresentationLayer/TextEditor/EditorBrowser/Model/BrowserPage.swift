import BlocksModels
import UIKit

final class BrowserPage: Equatable, CustomStringConvertible {
    let blockId: BlockId
    let title: String?
    let subtitle: String?
    
    weak var controller: UIViewController?
    let controllerHash: Int
    
    init(
        blockId: BlockId,
        title: String?,
        subtitle: String?,
        controller: UIViewController
    ) {
        self.blockId = blockId
        self.title = title
        self.subtitle = subtitle
        self.controller = controller
        self.controllerHash = controller.hash
    }
    
    static func == (lhs: BrowserPage, rhs: BrowserPage) -> Bool {
        guard let lhsController = lhs.controller, let rhsController = rhs.controller  else {
            return lhs.controllerHash == rhs.controllerHash
        }
        return lhsController.isEqual(rhsController)
    }
    
    var description: String {
        return """
        BlockId: \(blockId)
        Title: \(String(describing: title))
        Subtitle: \(String(describing: subtitle))
        Controller: \(String(describing: controller))
        """
    }
}
