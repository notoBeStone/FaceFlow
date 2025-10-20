//
//  AppUpgradeItem.swift
//  AINote
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLMP

class AppUpgradeItem: WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        
        //检查App更新
        AppUpgradeManager.updateInfo = GLMPAccount.getClientConfig()?.autoUpdate
        if AppUpgradeManager.checkUpdate() {
            return
        }
        completion(context)
    }
    
}
