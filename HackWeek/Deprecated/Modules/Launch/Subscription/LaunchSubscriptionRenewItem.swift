//
//  LaunchSubscriptionRenewItem.swift
//  AINote
//
//  Created by user on 2024/5/29.
//

import UIKit
import GLUtils
import GLMP
import GLModules

class LaunchSubscriptionRenewItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        guard let type = RenewRetentionManager.userAddEquityType else {
            completion(context)
            return
        }
        
        let vc = RenewRetentionViewController.init(addEquityType: type, from: "home") {
            context.interrupt = true
            completion(context)
        }
        
        vc.dismissClonse = {
            RenewRetentionManager.showAlertInfo { success in
                context.interrupt = true
                completion(context)
            }
        }
        UIViewController.gl_top().present(vc, animated: false)
    }
}
