//
//  UIViewController+Extension.swift
//  AINote
//
//  Created by xie.longyan on 2024/10/25.
//

import Foundation
import UIKit
import GLUtils

enum GLControllerPopType {
    case pop
    case popToRoot
}

extension UINavigationController {
    func contains(_ controller: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: controller) })
    }
}

extension UIViewController {
    func gl_popToRootControllerIfContains(_ controller: AnyClass, animated: Bool = true) {
        guard let navigationController = self.navigationController else { return }
        
        if navigationController.viewControllers.contains(where: { $0.isKind(of: controller) }) == true {
            navigationController.popToRootViewController(animated: animated)
        } else {
            navigationController.popViewController(animated: animated)
        }
    }
    
    @discardableResult
    func gl_popBeforeController(_ beforeController: AnyClass, popIfFailed: GLControllerPopType? = nil, animated: Bool = true) -> Bool {
        guard let navigationController = self.navigationController else {
            return false
        }
        
        if let index = navigationController.viewControllers.firstIndex(where: { $0.isKind(of: beforeController) }),
           index < navigationController.viewControllers.count - 1,
           let targetViewController = navigationController.viewControllers[safe: index + 1] {
            navigationController.popToViewController(targetViewController, animated: animated)
            return true
        }
        
        if let popIfFailed {
            gl_popController(popIfFailed, animated: animated)
        }
        
        return false
    }
    
    func gl_popController(_ defaultType: GLControllerPopType, animated: Bool = true) {
        guard let navigationController = self.navigationController else { return }
        
        switch defaultType {
        case .pop:
            navigationController.popToRootViewController(animated: animated)
        case .popToRoot:
            navigationController.popViewController(animated: animated)
        }
    }
    
    func gl_popToController(_ controller: AnyClass, animation: Bool = true, completion: @escaping (_ success: Bool) -> Void) {
        guard let navigationController = self.navigationController else {
            completion(false)
            return
        }

        navigationController.gl_pop(toController: controller, animated: animation, completion: { success in
            completion(success)
        })
    }
}
