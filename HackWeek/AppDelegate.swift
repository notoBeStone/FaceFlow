//
//  AppDelegate.swift
//  AINote
//
//  Created by 彭瑞淋 on 2022/9/29.
//

import UIKit
import GLUtils
import GLCore
import GLTrackingExtension
import GLAdjustExtension
import GLModules
import GLMP
import GLAdjust

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var orientation = UIInterfaceOrientationMask.portrait
    
    public var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        // 模板代码，勿动，无需研究
        TemplateWrapper.leagacyFininshLaunchinng()

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientation
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 模板代码，勿动，无需研究
        TemplateWrapper.leagacyDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // 模板代码，勿动，无需研究
        TemplateWrapper.leagacyDidEnterBackground()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // 模板代码，勿动，无需研究
        return TemplateWrapper.leagacyHandleOpenUrl(url: url)
    }
    
    
}
