//
//  CheckPaymentOrderItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLCore
import GLPurchaseExtension

class CheckPaymentOrderItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        //验证没有用户生成的情况下产生的后台订单,比如家庭包的共享成员
        GL().Purchase_VerifyNoUserBackgroudOrder { _, _, _ in
            completion(context)
        }
    }
    
}
