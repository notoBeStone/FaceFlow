//
//  SubscriptionItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLUtils

public protocol LaunchSubscriptionProtocol: WorkflowItem {
    
    func getSubItems() -> [WorkflowItem]
}

public extension LaunchSubscriptionProtocol {
    
    public func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        let subWorkflow = SubWorkflowItem(subItems: getSubItems())
        subWorkflow.execute(context) { context in
            completion(context)
        }
    }
}


class LaunchSubscriptionItem: LaunchSubscriptionProtocol {
    func getSubItems() -> [WorkflowItem] {
        return [LaunchDefaultVipPageItem()]
    }
}


class LaunchDefaultVipPageItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        Purchase.shared.checkFamilyAndRestore()
        let config = PurchaseUI.launchConfig
        VipPageLaunchManager.launchOpen(controller: UIViewController.gl_top(), isHistoryVip: PurchaseUI.isHistoryVip, vipConfig: config) { buySuccess, shown in
            completion(context)
        }
    }
}
