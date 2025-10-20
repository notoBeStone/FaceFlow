//
//  CheckPromotingPalaymentItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLCore
import GLWidget
import GLMP
import GLPurchaseExtension
import GLAccountExtension

class CheckPromotingPalaymentItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
//        GL().Purchase_SetInAppPurchaseInitiated { sku in
//            if !sku.isEmpty {
//                GLToast.showLoading()
//                GL().Purchase_PurchaseSubscription(sku: sku) { errorInfo, transactionId, result in
//                    GLToast.dismiss()
//                    
//                    let errorCode = errorInfo.simpleError
//                    let success: Bool = errorCode == .succeed
//                    let isPending: Bool = success && result == nil
//                    
//                    
//                    if isPending {
//                        //此时为pengind状态
//                        NotificationCenter.default.gl_postNotificationOnMainThread(withName: GLMediator.kVipInfoUpdateNotification, object: nil)
//                        completion(context)
//                        return
//                    }
//                    
//                    
//                    let showError: Bool = !success && errorCode != .purchaseCanceled
//                    if showError {
//                        GLToast.showError(GLModulesLanguage.TEXT_FAILED)
//                        completion(context)
//                        return
//                    }
//
//                    GLMPAccount.refreshUserAndVipInfo { _, _ in
//                        completion(context)
//                    }
//                }
//            } else {
//                completion(context)
//            }
//        }
        
        Purchase.promotingPurchaseInAppStore()
        completion(context)
    }
}
