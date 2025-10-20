//
//  MemberShipManager.swift
//  AINote
//
//  Created by Martin on 2023/12/19.
//

import Foundation
import GLCore
import GLPurchaseExtension
import GLPurchaseUIExtension
import GLWidget
import GLResource
import GLManageSubscriptionBase
import AppRepository
import GLMP
import GLModules
import AppConfig

class MemberShipManager: NSObject {
    
    static let shared = MemberShipManager()
    
    private override init() {
        
    }
    
    func openManageMemberShip() {
        let memo = MembershipConfig.defaultMemo ?? "Default"
        guard let vc = controller(withMemo: memo) else { return }
        GLManageSubEventManager.shared().delegate = self
        UIViewController.gl_top().navigationController?.pushViewController(vc, animated: true)
    }
    
    func openPayment() {
        PurchaseUI.purchase(from: "my_premium_service") { succeed in }
    }
    
    func restore() {
        GLToast.showLoading()
        GL().Purchase_RestoreSubscription { error, result in
            if error.simpleError == .succeed {
                GLMPAccount.restoreLogin(languageString: GLLanguage.currentLanguage.fullName, languageCode: GLLanguage.currentLanguage.languageId) { isSuccess, error in
                    GLToast.dismiss()
                }
            } else {
                GLToast.showError(GLMPLanguage.text_failed)
            }
        }
    }
    
    
    private func controller(withMemo memo: String) -> UIViewController? {
        if !memo.isEmpty {
            let className = "ManageSub\(memo)ViewController"
            if let cls = NSClassFromString(className) as? UIViewController.Type {
                return cls.init()
            }
        }
        return nil
    }
    
    private func popToHomeController() {
//        TabBarController.tabBarController?.jumpToRoot(type: .home)
    }
}

extension MemberShipManager: ManageSubscriptionProtocal {
    func openPaymentVC(withVC vc: UIViewController, vipClassName: String, fromPage: String, complete: @escaping (Bool) -> Void) -> UIViewController? {
        return UIViewController.gl_top()
    }
    
    func showToast(_ info: String?) {
        if let info = info {
            GLToast.showWarning(info)
        } else {
            GLToast.showLoading()
        }
    }
    
    func dismissToast() {
        GLToast.dismiss()
    }
    
    func showError(_ error: String?) {
        GLToast.showError(error)
    }
    
    func turnToAdvisoryVC() {
        
    }
    
    func turnToAttractingBirdVC() {
        
    }
    
    func turnToCrassulayVC() {
        
    }
    
    func turnToCustomerServiceVC() {
        
    }
    
    func turnToQAndAVC() {
        
    }
    
    func turnToCameraVC() {
        
    }
    
    func turnToPlantCareVC() {
        
    }
    
    func turnToIntructions() {
        
    }
    
    func trunToDiagnoseCamera() {
        
    }
    
    func dismissToHomeVC() {
        
    }
    
    func getSkuWithSkuKey(_ skuKey: String) -> String {
        // 1. {$.managemembership_sku} 确认是否需要
        // 2. 确认 setting，会员状态变更时列表中 managemembership 状态是否正确
        return ""
    }
    
    func getAppGlodYearSku() -> [Any] {
        return [""]
    }
    
    func getAppPlatinumYearSku() -> [Any] {
        return [""]
    }
    
    func getAppMonthSku() -> [Any] {
        return [""]
    }
    
    func getAppWeekSku() -> [Any] {
        return [""]
    }
    
    func getAppOtherSku() -> [Any] {
        return [""]
    }
}
