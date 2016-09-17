//
//  AppDelegate.swift
//  AppConfigSwift
//
//  The application delegate, handling global events while the app is running
//

import UIKit
import AppConfigSwift

class AppDelegate: UIResponder, UIApplicationDelegate {

    // --
    // MARK: Members
    // --
    
    var window: UIWindow?

    
    // --
    // MARK: Lifecycle callbacks
    // --
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if RELEASE
            // Disable library
        #else
            AppConfigStorage.shared.activate(manager: ExampleAppConfigManager.shared)
            AppConfigStorage.shared.setLoadingSourceAsset(filePath: Bundle.main.path(forResource: "AppConfig", ofType: "plist"))
        #endif
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

