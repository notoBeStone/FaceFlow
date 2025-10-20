//
//  LanuchRestoreItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLCore
import GLPurchaseUIExtension


class LanuchRestoreItem: WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        if GL().PurchaseUI_CanRestore() == .initState {
            GL().PurchaseUI_SetRestoreCallBack {
                completion(context)
            }
        } else {
            completion(context)
        }
    }
}
