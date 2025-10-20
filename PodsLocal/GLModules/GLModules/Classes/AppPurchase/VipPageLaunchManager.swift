//
//  VipPageLaunchManager.swift
//  AINote
//
//  Created by user on 2024/5/7.
//

import AppConfig
import Foundation
import GLABTestingExtension
import GLAccountExtension
import GLCore
import GLMP
import GLNetworking
import GLPurchaseUIExtension
import GLUtils

@objc
public class VipPageLaunchManager: NSObject {

    @objc public class func launchOpen(
        controller: UIViewController,
        isHistoryVip: Bool,
        vipConfig: GrowthVipPageConfig,
        callback: @escaping (_ buySuccess: Bool, _ shown: Bool) -> Void
    ) {
        if !vipConfig.isConversionEnable {
            callback(false, false)
            return
        }

        guard shouldShowRechargeView() else {
            callback(false, false)
            return
        }

        let vc = open(type: .addChild, controller: controller, isHistoryVip: isHistoryVip, vipConfig: vipConfig) {
            event,
            params in

            if event == GLMediator.VipEventClose {
                PurchaseUICache.updateConversionPageClosedTimesInHistory()
            }

            parsingAction(event: event, params: params) { buySuccess in
                callback(buySuccess, true)
            }
        }

        if vc == nil {
            callback(false, false)
        } else {
            NotificationCenter.default.rac_addObserver(forName: "promotion_buy_success_notification", object: nil)
                .subscribeNext { [weak vc] x in
                    vc?.view.removeFromSuperview()
                    vc?.removeFromParent()
                    callback(true, true)
                }
        }
    }

    @objc public class func open(
        type: GLPurchaseOpenType,
        controller: UIViewController,
        isHistoryVip: Bool,
        vipConfig: GrowthVipPageConfig,
        callback: @escaping (_ event: String, _ params: [AnyHashable: Any]?) -> Void
    ) -> UIViewController? {
        let item = ConversionPageItem.item
        var memo = item?.memo
        var group = item?.group
        var abtestingID = item?.id
        var originGroup = item?.originGroup

        if let specifiedMemo = vipConfig.specifiedMemo {
            memo = specifiedMemo
            group = nil
            originGroup = nil
            abtestingID = nil
        }
        let resultDic = vipConfig.extra

        let vc = GL().PurchaseUI_Open(
            memo ?? "",
            historyVipMemo: nil,
            isVipInHistory: isHistoryVip,
            vc: controller,
            type: type,
            languageString: vipConfig.languageString,
            languageCode: vipConfig.languageCode,
            from: vipConfig.from ?? "start",
            identifyCount: vipConfig.identifyCount,
            originGroup: originGroup,
            group: group,
            abtestingID: abtestingID,
            extra: resultDic,
            buyCancelClosePage: false
        ) { event, params in
            callback(event, params)
            return ""
        }
        return vc
    }

    @objc public class func open(
        type: GLPurchaseOpenType,
        controller: UIViewController,
        isHistoryVip: Bool,
        vipConfig: GrowthVipPageConfig,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        let _ = open(type: type, controller: controller, isHistoryVip: isHistoryVip, vipConfig: vipConfig) {
            event,
            params in
            parsingAction(event: event, params: params, callback: completion)
        }
    }
}

extension VipPageLaunchManager {

    private class func parsingAction(event: String, params: [AnyHashable: Any]?, callback: @escaping (Bool) -> Void) {
        switch event {
        case GLMediator.VipEventBuySuccess: callback(true)
        case GLMediator.VipEventClose: callback(false)
        case GLMediator.VipEventRestoreSuccess: callback(false)
        default:
            break
        }
    }

    private class func shouldShowRechargeView() -> Bool {
        let kVipAlertDate = "kVipAlertDate"  //转化页上次打开的时间
        let kVipAlertCount = "kVipAlertCount"  //转化页同一天弹出的次数
        var ret = false
        if !GL().Account_IsVip() {
            let canOpenVipBuyPage = GLNetworkingReachabilityTool.isReachable
            if canOpenVipBuyPage {
                ret = true
                if let alertDate = GLDefaults.object(forKey: kVipAlertDate) as? NSDate {
                    if alertDate.gl_isToday() {
                        let alertCount = (GLDefaults.object(forKey: kVipAlertCount) as? Int) ?? 0
                        if alertCount >= 2 {
                            return false
                        }
                        GLDefaults.setIntegerValue(alertCount + 1, forKey: kVipAlertCount)
                        return true
                    }
                }
                GLDefaults.setObject(NSDate(), forKey: kVipAlertDate)
                GLDefaults.setIntegerValue(1, forKey: kVipAlertCount)
            }
        }
        return ret
    }
}

public class GrowthVipPageConfig: NSObject {
    let languageString: String
    let languageCode: Int
    let identifyCount: Int
    @objc public var specifiedMemo: String?
    @objc public var extra: [String: Any] = [:]
    @objc public var from: String?
    @objc public var isConversionEnable: Bool = true  // 如果为True 不显示转化页

    @objc public init(languageString: String, languageCode: Int, identifyCount: Int) {
        self.languageString = languageString
        self.languageCode = languageCode
        self.identifyCount = identifyCount
        super.init()
    }
}

class ConversionPageItem {

    private static let LaunchConversionKey = "conversion_page"

    public static var item: ConversionPageItem? {
        if let model = GLMPABTesting.variableModel(key: LaunchConversionKey) {
            return ConversionPageItem(
                memo: model.variable,
                group: model.variableData,
                id: model.abtestingID,
                originGroup: model.originalVariable
            )
        }
        return nil
    }

    let memo: String
    let group: String?
    let id: String?
    // 表示 ab 的原始值, 之后在下发是__default 的时候才会有值 (originalVariable)
    let originGroup: String?

    init(memo: String, group: String?, id: String?, originGroup: String?) {
        self.memo = memo
        self.group = group
        self.id = id
        self.originGroup = originGroup
    }

}
