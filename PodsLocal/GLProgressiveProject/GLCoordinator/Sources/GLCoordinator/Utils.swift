//
//  File.swift
//  GLCoordinator
//
//  Created by stephenwzl on 2024/12/24.
//

import UIKit

@MainActor
func KeyWindow() -> UIWindow? {
    return UIApplication.shared.windows.first
}

extension UIViewController {
    static func topViewController(_ vc: UIViewController? = nil) -> UIViewController {
        var rootViewController = vc ?? KeyWindow()?.rootViewController
        
        if let presentedViewController = rootViewController?.presentedViewController {
            if presentedViewController == rootViewController {
                return rootViewController!
            }
            return Self.topViewController(presentedViewController)
        } else if let tabBarController = rootViewController as? UITabBarController {
            let controller = tabBarController.selectedViewController ?? tabBarController.viewControllers?.first
            if controller == rootViewController {
                return rootViewController!
            }
            return Self.topViewController(controller)
        } else if let navigationController = rootViewController as? UINavigationController {
            let controller = navigationController.visibleViewController ?? navigationController.viewControllers.first
            if controller == rootViewController {
                return rootViewController!
            }
            return Self.topViewController(controller)
        } else {
            return rootViewController!
        }
    }
}


