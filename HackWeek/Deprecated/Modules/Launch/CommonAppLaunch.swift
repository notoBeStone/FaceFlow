//
//  CustomLaunch.swift
//  AINote
//
//  Created by user on 2024/6/21.
//

import SwiftUI
import Foundation
import GLCore
import GLUtils
import GLMP
import GLModules
import GLWebView
import AppRepository
import IQKeyboardManager
import GLBizStorage
import GLResource
import AppModels


class CommonAppLaunch: LaunchWorkflowProtocol {
    
    func preloadWorkflowItems() -> [any WorkflowItem] {
        return [VipHistoryItem()]
    }
    
    var requestHeaderItem: GLModules.NetworkHeaderConfigItemProtocol? {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return nil
        }
#endif
        return AdditionalRequestHeadersHandler()
    }
    
    var jsbConfigItem: GLModules.JSBConfigItemProtocol? {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return nil
        }
#endif
        return AppJSBConfigItem()
    }
    
    var npsConfigItem: GLModules.NPSConfigItemProtocol? {
        return nil
    }
    
    var subscriptionItem: GLModules.LaunchSubscriptionProtocol? {
        return AppLaunchSubscriptionItem()
    }
    
    var screenshotItem: GLModules.ScreenshotTrackingItemProtocol? {
        return nil
    }
    
    
    var adjustConfigItem: AdjustConfigItemProtocol? {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return nil
        }
#endif
        return AppAdjustDeeplinkItem()
    }
    
    func afterUserInitWorkflowItems() -> [WorkflowItem] {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return []
        }
#endif
        return [
            AppDeeplinkRegisterConfigItem(),
            AppearanceUIConfigItem(),
//            DataMigrationItem()
        ]
    }
    
    
    func onNext() {
        Self.showMainViewController()
    }
    
    static func showMainViewController() {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
#endif
        
        guard let window = KeyWindow() else {
            return
        }
        window.rootViewController = BaseNavigationViewController(rootViewController: TemplateHostingController(TemplateConfig.rootView, from: nil))
        window.makeKeyAndVisible()
    }
}

struct RootViewWrapper: View {
    let provider: AnyView
    var body: some View {
        provider
    }
}


class AppAdjustDeeplinkItem: AdjustConfigItemProtocol {
    
    func adjustDeeplinkHandler(_ url: URL?) {
        //        #warning("todo")
    }
}

class AppJSBConfigItem: JSBConfigItemProtocol {
    func getRegisterJSBImplements() -> [JSBImplement] {
        return [RootJSBridgeImplement()]
    }
    
    func getAvailableDomains() -> [String] {
        return ["AINoteai.com"]
    }
}


class AppLaunchSubscriptionItem: LaunchSubscriptionProtocol {
    func getSubItems() -> [GLModules.WorkflowItem] {
        var items: [WorkflowItem] = []
        // IMPORTANT: 由于 skuModel是在 init的时候加载，所以需要找个合适的时机 init一下
        Purchase.shared.donothing()
        
        if GLMPAccount.isVip() {
            if PaymentBarrierManager.isPaymentBarrier() {
                items.append(LaunchSubscriptionPaymentBarrierItem())
            }
            if let _ = RenewRetentionManager.userAddEquityType {
                items.append(LaunchSubscriptionRenewItem())
            }
        } else {
            if GL().PurchaseUI_CanRestore() == .canRestore {
                items.append(LaunchSubscriptionAutoRestoreItem())
            } else {
                items.append(LaunchSubscriptionConversionItem())
            }
        }
        
        return items
    }
    
    
}


fileprivate class AppearanceUIConfigItem: WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        GLResponsiveLayout.sampleWith = ScreenWidth
        GLResponsiveLayout.ipadZoomScale = 1.0
        
        IQKeyboardManager.shared().isEnabled = true
        
        UITableView.appearance().sectionHeaderTopPadding = 0
        // TODO: MVP版本只支持英文
        GLLanguage.updateCode("en")
        GLMPAccount.updateDeviceInfo(languageString: GLLanguage.currentLanguage.fullName)
        // force light mode
        KeyWindow()?.overrideUserInterfaceStyle = .light
        completion(context)
    }
}


fileprivate class AppUserDataConfigItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        
        UserCoreDataManager.shared.launchLoad()
        
        completion(context)
    }
}


fileprivate class AppDeeplinkRegisterConfigItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        
        DeepLinks.shared.registerRouter()
        
        completion(context)
    }
}


fileprivate class DataMigrationItem: WorkflowItem {
    let dataMigrationKey: String = "dataMigrationKey"
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        completion(context)
    }
}


fileprivate class VipHistoryItem: WorkflowItem {
    func execute(_ context: GLModules.WorkflowContext, completion: @escaping (GLModules.WorkflowContext) -> Void) {
        VipHistoryManager.shared.setup()
        completion(context)
    }
    
    
}
