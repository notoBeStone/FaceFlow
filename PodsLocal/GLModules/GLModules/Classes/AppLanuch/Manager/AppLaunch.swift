//
//  AppLaunch.swift
//  AINote
//
//  Created by Martin on 2023/6/25.
//

import UIKit
import GLUtils
import GLAnalyticsUI

import GLResource
import GLCore
//import GLWebView
import GLConfig_Extension
import GLWebImageExtension
import GLTrackingExtension
import GLAgreement_Extension
import GLPurchaseUIExtension
import GLMP
//import AppRepository

//MARK: - Flow
public class AppLaunch {

    public static func launch(with customWorkflow: LaunchWorkflowProtocol? = nil) {
        
        let workflow: Workflow = Workflow()
        
        var launchImpl: LaunchWorkflowProtocol = DefaultLaunchWorkflow()
        if let customWorkflow = customWorkflow {
            launchImpl = customWorkflow
        }
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            //进首页
            workflow.executeWorkflow { context in
                launchImpl.onNext()
            }
            return
        }
#endif
        workflow.addItem(AppReinstallItem())
        
        workflow.addItem(launchImpl.requestHeaderItem ?? NetworkHeaderConfigItem())
        //埋点
        workflow.addItem(TrackingConfigItem())
        //推介购买
        workflow.addItem(CheckPromotingPalaymentItem())
        //启动占位
        workflow.addItem(SplashItem(splashVC: launchImpl.LoadingUI()))
        //配置debugger工具
//        workflow.addItem(DebuggerConfigItem())
        //Adjust
        workflow.addItem(launchImpl.adjustConfigItem ?? AdjustConfigItem())
        //预加载自定义
        workflow.addItem(PreloadWorkflowItem(subItems: launchImpl.preloadWorkflowItems()))
        //加载AB
        workflow.addItem(LoadABItem())
        
        //展示协议
        workflow.addItem(AgreementItem())
        //自定义协议后
        workflow.addItem(AfterAgreementWorkflowItem(subItems: launchImpl.afterAgreementWorkflowItems()))
        
        //用户初始化
        workflow.addItem(UserInitItem())
        //App升级
        workflow.addItem(AppUpgradeItem())
//        workflow.addItem(CheckPromotingPalaymentItem())
        //后台订单校验
        workflow.addItem(CheckPaymentOrderItem())
        //restore
        workflow.addItem(LanuchRestoreItem())
        //图片配置
        workflow.addItem(WebImageConfigItem())
        //上传配置
        workflow.addItem(UploadConfigItem())
        //NPS配置
        workflow.addItem(launchImpl.npsConfigItem ?? NPSConfigItem())
        //用户Tag配置
        workflow.addItem(UserTagsConfigItem())
        //截屏监控
        workflow.addItem(launchImpl.screenshotItem ?? DefaultScreenshoTrackingParamsItem())
        //jsb
        workflow.addItem(launchImpl.jsbConfigItem ?? JSBConfigItem())
        
        //自定义用户初始化后
        workflow.addItem(AfterUserInitWorkflowItem(subItems: launchImpl.afterUserInitWorkflowItems()))
        
        //转化页过程集
        workflow.addItem(launchImpl.subscriptionItem ?? LaunchSubscriptionItem())
        //进首页
        workflow.executeWorkflow { context in
            launchImpl.onNext()
        }
    }

    
}
