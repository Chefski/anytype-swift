import Foundation
import SwiftProtobuf
import Lib

/// Begin of classes

/// Adapts interface of private framework.
public protocol ServiceEventsHandlerProtocol: AnyObject {
    func handle(_ data: Data?)
}

/// Provides the following functionality
/// - Receive events from `Lib` and transfer them to a wrapped value.
///
/// In a nutshell, it do the following.
///
/// - It consumes ( with a weak ownership ) a value which adopts public interface.
/// - Subscribes as event handler to library events stream.
/// - Transfer events from library to a value.
///
public class ServiceMessageHandlerAdapter: NSObject {
    public typealias Adapter = ServiceEventsHandlerProtocol
    private(set) weak var value: Adapter?
    public init(value: Adapter) {
        self.value = value
        super.init()
        self.listen()
    }
    public override init() {
        super.init()
    }
    public func with(value: Adapter?) -> Self {
        self.value = value
        if value != nil {
            self.listen()
        }
        return self
    }
    /// Don't forget to call it.
    public func listen() {
        Lib.ServiceSetEventHandlerMobile(self)
    }
}

/// Private `ServiceMessageHandlerProtocol` adoption.
extension ServiceMessageHandlerAdapter: ServiceMessageHandlerProtocol {
    public func handle(_ b: Data?) {
        self.value?.handle(b)
    }
}

/// End of classes
