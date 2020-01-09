//
//  Services.swift
//  AnyType
//
//  Created by Lobanov Dmitry on 19.11.19.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit

protocol ServicesInfoProtocol {
    var health: Bool {get}
    static var name: String {get}
}

protocol ServicesSetupProtocol {
    func setup()
    func tearDown()
}

protocol ServicesOnceProtocol {
    func runAtFirstTime()
}

class BaseService: NSObject {}

extension BaseService: ServicesInfoProtocol {
    @objc var health: Bool {
        return false
    }
    static var name: String {
        return self.description()
    }
}

extension BaseService: ServicesSetupProtocol {
    @objc func setup() {}
    @objc func tearDown() {}
}

extension BaseService: ServicesOnceProtocol {
    @objc func runAtFirstTime() {}
}

extension BaseService: UIApplicationDelegate {

}

//extension BaseService: UISceneDelegate {
//
//}

// MARK: Services Manager.
class ServicesManager: NSObject {
    //MARK: Shared
    static let shared: ServicesManager = ServicesManager()
    var services: [BaseService] = []
    static var manager: ServicesManager {
        return shared
    }
    override init() {
        services = [
            AppearanceService()
        ]
    }
    func setup() {
        for service in services as [ServicesSetupProtocol] {
            service.setup()
        }
    }
    func tearDown() {
        for service in services as [ServicesSetupProtocol] {
            service.tearDown()
        }
    }

    func runAtFirstTime() {
        storageSettings()
    }
    func interServiceSetup() {}
}

//MARK: Settings.
//It is the best place to change them.
//We need production settings.
extension ServicesManager {
    //HINT: the best place to change default settings to something else.
    func storageSettings() {}
}

//MARK: Accessors
extension ServicesManager {
    func service<T>(for search: T.Type) -> T? where T: BaseService  {
        return self.services.filter { (item) in
            return type(of: item) === search
            }.first as? T
    }
    func service(name: String) -> BaseService? {
        let service = services.filter {type(of: $0).name == name}.first
        if service == nil {

        }
        return service
    }
}

extension ServicesManager: UIApplicationDelegate {
    func servicesUIDelegates() -> [UIApplicationDelegate] {
        return services as [UIApplicationDelegate]
    }

    func applicationWillTerminate(_ application: UIApplication) {
        tearDown()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        setup()

        runAtFirstTime()
        interServiceSetup()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationDidBecomeActive?(application)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationWillResignActive?(application)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationDidEnterBackground?(application)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationWillEnterForeground?(application)
        }
    }
}
