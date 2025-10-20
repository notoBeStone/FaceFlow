//
//  Purchase.swift
//  AINote
//
//  Created by Martin on 2022/10/20.
//

import AppConfig
import Foundation
import GLCore
import GLDatabase
import GLMP
import GLPurchaseExtension
import GLPurchaseUIExtension
import GLResource
import GLTrackingExtension
import GLWidget
import StoreKit
import GLComponentAPI
import GLNetworking
import GLLottie

public class Purchase {

    public static var promatingSku: String? = nil

    @objc public var isVipInHistory: Bool {
        VipHistoryManager.shared.isVipInHistory
    }

    @objc public var isFamilyShared: Bool {
        VipHistoryManager.shared.isVipFamilyShared
    }

    public static var shared = Purchase()

    private init() {
        self.config()
    }
    
    public func donothing() {
        // IMPORTANT: 由于 skuModel是在 init的时候加载，所以需要找个合适的时机 init一下
    }

    private func config() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: GLMediator.kUserDeleteNotification),
            object: nil,
            queue: .main
        ) { _ in
            GL().Purchase_RemoveAllPendingTransactions()
        }

        GL().Purchase_SetupSkuModels(models: SKUConfig.purchaseSkus)
        GL().PurchaseUI_Setup(
            defaultVipPage: PurchaseUI.defaultTrailMemo,
            defaultHistoryVipPage: PurchaseUI.defaultHistoryMemo
        )
        GL().Purchase_FetchProducts(GL().Purchase_GetAllSku(), handler: nil)
        GL().Purchase_SetRestoreCoverNewUser { [weak self] handler in
            self?.restoreUserCoverBuyOthers(handler: handler)
        }
    }

    private func restoreUserCoverBuyOthers(handler: @escaping (Bool) -> Void) {
        let vc = RestoreOtherUserAlertViewController()
        UIViewController.gl_top().present(vc, animated: true)
        vc.handler = { confirm in
            handler(confirm)
        }
    }

    public func restore(completion: @escaping (_ succeed: Bool) -> Void) {
        if !GLNetworkingReachabilityTool.isReachable {
            GLToast.showWarning(GLModulesLanguage.text_no_connection)
            return
        }

        guard let userId = GLMPAccount.getUserId() else {
            GLToast.showWarning(GLModulesLanguage.text_no_connection)
            return
        }

        GLToast.showLoading()
        GL().Purchase_RestoreSubscription { error, result in
            let simpleError = error.simpleError
            if simpleError == .restoreSkiped {
                GLToast.dismiss()
                completion(false)
                return
            }

            if simpleError != .succeed && simpleError != .purchaseCanceled {
                GLToast.showError(GLModulesLanguage.text_retore_empty)
                return
            }

            if let newUserId = GLMPAccount.getUserId(), userId != newUserId {
                self.restoreLogin(userId: newUserId) {
                    GLToast.dismiss()
                    completion(true)
                }
            } else {
                GLToast.dismiss()
                completion(true)
                return
            }
        }
    }

    private func restoreLogin(userId: String, _ completion: @escaping () -> Void) {
        GLMPAccount.setAccessToken(nil)

        let loginInfo = GLAPILoginInfo()
        loginInfo.loginType = .RESTORE
        loginInfo.loginKey = userId
        GLMPAccount.login(
            loginInfo: loginInfo,
            loginAction: .ONLY_LOGIN,
            languageString: GLLanguage.currentLanguage.fullName,
            languageCode: GLLanguage.currentLanguage.languageId
        ) { _, _ in
            completion()
        }
    }

    public func checkFamilyAndRestore() {
        if GLMPAccount.getUser() != nil
            && !GLMPAccount.isVip()
            && self.isFamilyShared
        {
            GL().Purchase_RestoreSubscription { _, _ in }
        }
    }

    public func buyAndVerifyProduct(
        _ sku: String,
        count: Int = 1,
        isConsumable: Bool = false,
        compltion: @escaping (PurchaseError) -> Void
    ) {
        GLToast.showLoading()
        if isConsumable {  //消耗品购买
            GL().Purchase_PurchaseConsumables(sku: sku, quantity: count) { errorInfo, transactionId, result in
                let errorCode: PurchaseError = errorInfo.simpleError
                let success: Bool = errorCode == .succeed
                let showError: Bool = !success && errorCode != .purchaseCanceled
                if showError {
                    GLToast.showError(GLModulesLanguage.text_failed)
                    compltion(errorCode)
                    return
                }

                GLMPAccount.refreshUserAndVipInfo { _, _ in
                    GLToast.dismiss()
                    compltion(errorCode)
                }
            }

        } else {  //订阅购买
            GL().Purchase_PurchaseSubscription(sku: sku) { errorInfo, transactionId, result in
                let errorCode: PurchaseError = errorInfo.simpleError
                let success: Bool = errorCode == .succeed
                let isPending: Bool = success && result == nil

                if isPending {
                    GLToast.dismiss()
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: GLMediator.kVipInfoUpdateNotification),
                        object: nil
                    )
                    compltion(errorCode)
                    return
                }

                let showError: Bool = !success && errorCode != .purchaseCanceled
                if showError {
                    GLToast.showError(GLModulesLanguage.text_failed)
                    compltion(errorCode)
                    return
                }

                GLMPAccount.refreshUserAndVipInfo { _, _ in
                    GLToast.dismiss()
                    compltion(errorCode)
                }
            }
        }
    }
}

// MARK: - Notifiaction Define
extension Purchase {
    public static let kPurchasePromotingBuySuccessNotification = "kPurchasePromotingBuySuccessNotification"
}

// MARK: - Promation
extension Purchase {

    public static func promotingPurchaseInAppStore() {
        GL().Purchase_SetInAppPurchaseInitiated { sku in
            GLMPTracking.tracking("promoting", parameters: [GLT_PARAM_NAME: "buy"])
            if GLMPAccount.getUserId() != nil && sku.count > 0 {
                Purchase.promatingSku = nil
                Purchase.shared.buyAndVerifyProduct(sku) { error in
                    if error == .succeed {
                        GLMPTracking.tracking("promoting", parameters: [GLT_PARAM_NAME: "success"])
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: kPurchasePromotingBuySuccessNotification),
                            object: nil
                        )
                    } else {
                        GLMPTracking.tracking("promoting", parameters: [GLT_PARAM_NAME: String(error.rawValue)])
                    }
                }
            } else {
                Purchase.promatingSku = sku
            }
        }
    }

}
