//
//  UserInitItem.swift
//  AINote
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLResource
import GLCore
import GLMP
import GLUtils

class UserInitItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        guard let splashVC = context.params["splashVC"] as? AppLaunchSplashProtocol else {
            assertionFailure("splashVC not set in workflow context")
            return
        }
        
        UserInitItem.tryInitialise(splashVC) {
            //更新埋点组件userId
            if let userId = GLMPAccount.getUserId() {
                GLMPTracking.setUserId(userId)
            }
            
            completion(context)
        }
        
    }
    
    private static func tryInitialise(_ splashVC: AppLaunchSplashProtocol, completion: @escaping () -> Void) {
        
        GLMPAccount.userInitialise { success in
            if success {
                completion()
            } else {
                splashVC.showErrorUI {
                    UserInitItem.tryInitialise(splashVC, completion: completion)
                }
            }
        }
    }
    
}
