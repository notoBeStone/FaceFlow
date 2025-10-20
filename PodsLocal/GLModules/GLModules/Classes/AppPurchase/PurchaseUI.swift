//
//  PurchaseUI.swift
//  AINote
//
//  Created by Martin on 2022/10/21.
//

import AppConfig
import DGMessageAPI
import GLABTestingExtension
import GLBaseApi
import GLCore
import GLMP
import GLPurchaseUIExtension
import GLResource
import GLUtils
import UIKit

public class PurchaseUI: NSObject {

    private static let kConversionPage: String = "conversion_page"

    public static var defaultTrailMemo: String {
        return ConversionConfig.defaultMemo
    }

    public static var defaultHistoryMemo: String {
        return ConversionConfig.historyMemo
    }

    public static var isHistoryVip: Bool {
        Purchase.shared.isVipInHistory
    }

    public static func purchase(memo: String, from: String, completion: ((_ succeed: Bool) -> Void)? = nil) {
        let tabBarController = UIViewController.gl_top()
        purchase(
            memo: memo,
            viewController: tabBarController,
            type: .present,
            from: from,
            extra: nil,
            completion: { succeed in
                completion?(succeed)
            }
        )
    }

    public static func purchase(
        from: String,
        viewController: UIViewController? = nil,
        completion: @escaping (_ succeed: Bool) -> Void
    ) {
        var vc = viewController
        if vc == nil {
            vc = UIViewController.gl_top()
        }
        self.purchase(
            memo: self.defaultMemo,
            viewController: vc,
            type: .present,
            from: from,
            extra: nil,
            completion: completion
        )
    }

    public static var launchConfig: GrowthVipPageConfig {
        let config = GrowthVipPageConfig(
            languageString: GLLanguage.currentLanguage.fullName,
            languageCode: GLLanguage.currentLanguage.languageId,
            identifyCount: 0
        )
        config.extra = self.extra ?? [:]
        config.isConversionEnable = !VipHistoryManager.shared.isVipFamilyShared
        return config
    }

    // MARK: - Private
    private static var defaultMemo: String {
        let defaultMemo = Purchase.shared.isVipInHistory ? self.defaultHistoryMemo : self.defaultTrailMemo 
        return GLMPABTesting.variable(key: PurchaseUI.kConversionPage, activate: false) ?? defaultMemo
    }

    private static var extra: [String: Any]? {
        //todo
        return [:]
    }

    private static func purchase(event: String, completion: @escaping (_ succeed: Bool) -> Void) {
        switch event {
        case GLMediator.VipEventBuySuccess:
            self.buySucceed(completion)
        case GLMediator.VipEventRestoreSuccess:
            self.restoreSucceed(completion)
        case GLMediator.VipEventClose:
            self.close(completion)
        case GLMediator.VipEventBuyCancell:
            self.cancelBuy(completion)
        default:
            break
        }
    }

    private static func buySucceed(_ completion: @escaping (_ succeed: Bool) -> Void) {
        completion(true)
    }

    private static func restoreSucceed(_ completion: @escaping (_ succeed: Bool) -> Void) {
        completion(true)
    }

    private static func close(_ completion: @escaping (_ succeed: Bool) -> Void) {
        completion(false)
    }

    private static func cancelBuy(_ completion: @escaping (_ succeed: Bool) -> Void) {}

    private static func purchase(
        memo: String,
        viewController: UIViewController? = nil,
        type: GLPurchaseOpenType,
        from: String,
        extra: [String: Any]?,
        completion: @escaping (_ succeed: Bool) -> Void
    ) {
        var purchaseExtra: [String: Any] = [:]
        if let extra = self.extra {
            purchaseExtra = purchaseExtra.gl_merge(extra)
        }

        if let extra = extra {
            purchaseExtra = purchaseExtra.gl_merge(extra)
        }

        let vc = viewController ?? UIViewController.gl_top()
        let _ = GL().PurchaseUI_Open(
            memo,
            historyVipMemo: nil,
            isVipInHistory: Self.isHistoryVip,
            vc: vc,
            type: type,
            languageString: GLLanguage.currentLanguage.fullName,
            languageCode: GLLanguage.currentLanguage.languageId,
            from: from,
            identifyCount: 0,
            originGroup: nil,
            group: nil,
            abtestingID: nil,
            extra: purchaseExtra
        ) { event, _ in
            self.purchase(event: event, completion: completion)
            return ""
        }
    }
}
