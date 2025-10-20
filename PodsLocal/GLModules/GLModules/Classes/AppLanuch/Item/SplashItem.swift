//
//  SplashItem.swift
//  AINote
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLUtils


class SplashItem: WorkflowItem {
    
    let splashVC: AppLaunchSplashProtocol
    
    init(splashVC: AppLaunchSplashProtocol) {
        self.splashVC = splashVC
    }
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        showSplash()
        context.params["splashVC"] = splashVC
        completion(context)
    }
    
    private func showSplash() {
        guard let window = KeyWindow() else { return }
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }
}
