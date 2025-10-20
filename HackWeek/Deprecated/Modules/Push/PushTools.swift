//
//  PushTools.swift
//  DangJi
//
//  Created by Martin on 2022/3/29.
//  Copyright © 2022 Glority. All rights reserved.
//

import UIKit
import GLCore
import GLResource
import GLTrackingExtension
import GLMP

@objc
class PushTools: NSObject {
    @objc static var shared = PushTools()
    
    private override init() {
        super.init()
    }
    
    func config() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
    }
    
    func registerForRemoteNotificationsWithError(_ error: Error) {
        var errorMessage = ""
        if let error = error as NSError? {
            errorMessage = error.localizedDescription
        }
        GL().Tracking_Error("register_for_remotion_notification_failed", errorMessage: errorMessage)
    }
    
    func registerForRemoteNotificationsWithDeviceToken(_ token: Data?) {}
    
    func didReceive(request: UNNotificationRequest, foreground: Bool) {
        //todo
//        self.enable = true
//        self.parseDeeplink(deeplink, delegate: delegate)
    }
    
    
    public static func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}



// MARK: - UNUserNotificationCenterDelegate
extension PushTools: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        didReceive(request: notification.request, foreground: true)
        completionHandler([.sound, .badge, .list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //todo
        didReceive(request: response.notification.request, foreground: false)
    }
    
}
