import Foundation

protocol AlertOpenerProtocol: AnyObject {
    func showTopAlert(message: String)
    func showLoadingAlert(message: String) -> AnytypeDismiss
    func showFloatAlert(model: BottomAlert) -> AnytypeDismiss
}