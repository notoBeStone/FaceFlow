//
//  LaunchSubscriptionConversionItem.swift
//  AINote
//
//  Created by user on 2024/3/29.
//

import Foundation
import GLUtils
import GLModules

class LaunchSubscriptionConversionItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        if TemplateConfig.showConversionAtLaunch {
            Self.standloneExec {
                completion(context)
            }
        } else {
            completion(context)
        }
    }
    
    static func standloneExec(_ completion: (() -> Void)? = nil) {
        Purchase.shared.checkFamilyAndRestore()
        let config = PurchaseUI.launchConfig
        VipPageLaunchManager.launchOpen(controller: UIViewController.gl_top(), isHistoryVip: PurchaseUI.isHistoryVip, vipConfig: config) { buySuccess, shown in
            completion?()
        }
    }
}
