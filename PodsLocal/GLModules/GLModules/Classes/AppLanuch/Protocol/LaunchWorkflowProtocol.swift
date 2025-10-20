//
//  AppLaunchWorkflowProtocol.swift
//  AINote
//
//  Created by user on 2024/6/20.
//

import Foundation
import UIKit
import GLUtils
import GLMP


public protocol AppLaunchSplashProtocol: UIViewController {
    func showErrorUI(_ retry: @escaping () -> Void)
}


public protocol LaunchWorkflowProtocol {
    
    func LoadingUI() -> AppLaunchSplashProtocol
    
    //在流程开始前执行
    func preloadWorkflowItems() -> [WorkflowItem]
    
    //在用户同意协议后执行
    func afterAgreementWorkflowItems() -> [WorkflowItem]
    
    //在用户初始化后执行
    func afterUserInitWorkflowItems() -> [WorkflowItem]
    
    //在转化页之后执行（可能不弹转化页，会执行）
    func afterVipPageWorkflowItems() -> [WorkflowItem]
    
    //启动流程结束回调
    func onNext()
    
    
    //Adjsut
    var adjustConfigItem: AdjustConfigItemProtocol? { get }
    
    
    //JSB
    var jsbConfigItem: JSBConfigItemProtocol? { get }
    
    //NPS
    var npsConfigItem: NPSConfigItemProtocol? { get }
    
    //转化页流程
    var subscriptionItem: LaunchSubscriptionProtocol? { get }
    
    
    //截屏监控回调
    var screenshotItem: ScreenshotTrackingItemProtocol? { get }
    
    //网络请求header处理回调
    var requestHeaderItem: NetworkHeaderConfigItemProtocol? { get }

}

public extension LaunchWorkflowProtocol {
    
    func LoadingUI() -> AppLaunchSplashProtocol {
        return PlaceholderViewController()
    }
    
    func preloadWorkflowItems() -> [WorkflowItem] {
        return []
    }
    
    func afterAgreementWorkflowItems() -> [WorkflowItem] {
        return []
    }
    
    func afterUserInitWorkflowItems() -> [WorkflowItem] {
        return []
    }
    
    func afterVipPageWorkflowItems() -> [WorkflowItem] {
        return []
    }
}



class DefaultLaunchWorkflow: LaunchWorkflowProtocol {
    var requestHeaderItem: NetworkHeaderConfigItemProtocol? {
        return nil
    }
    
    var subscriptionItem: LaunchSubscriptionProtocol? {
        return nil
    }
    
    var npsConfigItem: NPSConfigItemProtocol? {
        return nil
    }
    
    var jsbConfigItem: JSBConfigItemProtocol? {
        return nil
    }
    
    var screenshotItem: ScreenshotTrackingItemProtocol? {
        return nil
    }
    
    var adjustConfigItem: AdjustConfigItemProtocol? { return nil }
    
    func onNext() { }
}
