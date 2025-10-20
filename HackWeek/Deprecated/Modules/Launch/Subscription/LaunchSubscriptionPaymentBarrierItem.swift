//
//  LaunchSubscriptionPaymentBarrierItem.swift
//  AINote
//
//  Created by user on 2024/5/29.
//

import UIKit
import GLUtils
import GLModules

//支付障碍
class LaunchSubscriptionPaymentBarrierItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        guard PaymentBarrierManager.canShow() else {
            completion(context)
            return
        }
        
        PaymentBarrierManager.showPopView {
            completion(context)
        }
    }
}
