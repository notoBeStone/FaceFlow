//
//  RenewRetentionManager.swift
//  AINote
//
//  Created by user on 2024/5/30.
//

import Foundation
import GLUtils
import GLDatabase
import GLComponentAPI
import GLCore
import GLPurchaseExtension
import GLMP

// 活动通知

class RenewRetentionManager {
    
    enum RenewType: String {
        case valueDefault = "110457"
        
        // 多语言
        case valueMutLanguage = "110646"
    }
    
    static let shared = RenewRetentionManager()
    
    private init() {
        
    }
    
    
    private static let abKey: String = "onetime_homepop_ab"
    
    //两个方案要共用同一个存储Key，防止触发后再次触发
    private static let hasShowStoreKey: String = "home_add_equity_show_1335_key"
    static let hasTapRequestStoreKey: String = "home_add_equity_tap_add_equity_1335_key"
    private static let requestFailedStoreKey: String = "add_equity_request_failed_1335_key"

    private static let familySkus: [String] = ["us_sub_vip_family_14dt", "us_sub_vip_family_7dt", "us_sub_vip_family_7dt_29.99"]
    
    // 一次性付费的SKU
    private static let onePaymentSkus: [String] = ["us_sub_vip_1year", "us_sub_vip_2years", "us_sub_vip_3years"]

    static var userSku: String?

    @objc
    class var isAddEquityUser: Bool {
        get {
            return GLCache.bool(forKey: hasTapRequestStoreKey)
        }
        
        set {
            GLCache.setBool(newValue, forKey: hasTapRequestStoreKey)
        }
    }
    
    //那个类型是否满足条件
    class var userAddEquityType: RenewType? {
        if !abCondition {
            return nil
        }
        // 两个实验都需要SKU，和 isTrial
        let vipInfo = GLMPAccount.getVipInfo()
        guard let isTrial = vipInfo?.isTrial,
              let _ = vipInfo?.sku else {
            return nil
        }
        // 试用期会员 多语言
        if isTrial.boolValue == true {
            // 试用期方案已删除，直接返回nil即可
            return nil
        } else {
            guard let abValue = GLMPABTesting.variable(key: abKey) else {
                return nil
            }
            return RenewType(rawValue: abValue)
        }
    }
    //开屏弹窗的AB实验条件
    private class var abCondition: Bool {
        if hasShow {
            return false
        }
        return baseCondition
    }
    
    //方案基本条件
    private class var baseCondition: Bool {

        //排除善意假定用户
        if GLMPAccount.isFakeVip() {
            return false
        }
        
        //VIP 用户
        if !GLMPAccount.isVip() {
            return false
        }
        guard let vipInfo = GLMPAccount.getVipInfo() else {
            return false
        }
        
        //自动续订排除
        let isAutoRenew = vipInfo.isAutoRenew?.boolValue ?? true
        if isAutoRenew {
            return false
        }
        
        //排除SKU 为空时 或者 家庭包
        if vipInfo.sku == nil || isFamilyUser(sku: vipInfo.sku) {
            return false
        }
        
        // 排除一次性付费的用户
        if isOnePaymentUser(sku: vipInfo.sku) {
            return false
        }
        
        if isSpecialSku(vipInfo.sku) {
            return false
        }
        //SKU 给过去
        userSku = vipInfo.sku
        return true
    }
    
    //是不是家庭包SKU
    class func isFamilyUser(sku: String?) -> Bool {
        guard let sku = sku else {
            return false
        }
        let item = familySkus.first { newItem in
            return NSString(string: newItem).isEqual(to: sku)
        }
        if item == nil {
            return false
        }
        return true
    }
    
    // 是不是一次性付费的SKU onePaymentSkus
    class func isOnePaymentUser(sku: String?) -> Bool {
        guard let sku = sku else {
            return false
        }
        let item = onePaymentSkus.first { newItem in
            return NSString(string: newItem).isEqual(to: sku)
        }
        if item == nil {
            return false
        }
        return true
    }
    
    //是不是周、月 季包, 半年包也会排除
    class func isSpecialSku(_ sku: String?) -> Bool {
        guard let sku = sku, sku.count > 0 else {
            return false
        }
        guard let model = GL().Purchase_GetSkuModel(forSku: sku) as? SkuSubscriptionModel else {
            return false
        }
        return model.period == .weekly || model.period == .monthly || model.period == .seasonly
    }
    
    //MARK: - show
    class var hasShow: Bool {
        return GLCache.bool(forKey: hasShowStoreKey)
    }
    
    class func shownAction() {
        GLCache.setBool(true, forKey: hasShowStoreKey)
    }
    
    //Item models
    class var itemList: [RenewRetentionManager.EquityItemModel] {
      return [moreDayEquityModel,
              askExpertModel,
              bookModel]
    }
    // update user equity
    public class func updateUserEquity() {
        if GLCache.bool(forKey: requestFailedStoreKey) {
            addVipRenewRights { finish in
                // do nothing
            }
        }
    }
    
    //Request
    public class func addVipRenewRights(complete: ((Bool)->())?) {
        complete?(false)
        //todo
//        let request = VipplantAddVipRenewRightsRequest.init()
//        // 只要调用就先设置为Failed
//        GLCache.setBool(true, forKey: requestFailedStoreKey)
//        YSHttpManager.sharedMessageAPINetworkingManager().request(request, completion:  { response in
//            if let _ = response.error {
//                complete?(false)
//                return;
//            }
//            if response.processedData != nil {
//                GLCache.setBool(true, forKey: hasTapRequestStoreKey)
//                GLCache.setBool(false, forKey: requestFailedStoreKey)
//                complete?(true)
//            } else {
//                complete?(false)
//            }
//        })
    }
    
    @objc
    class func initStatisticsData(complete: ((Int)->())?) {
        complete?(0)
        //todo
//        let request = ApplicationGetUserStatisticsRequest.init()
//        YSHttpManager.sharedMessageAPINetworkingManager().request(request, completion: { response in
//            if let _ = response.error {
//                complete?(0)
//                return
//            }
//            if let model = response.processedData as? ApplicationGetUserStatisticsResponse {
//                complete?(model.userStatistics.unlockedBook)
//            } else {
//                complete?(0)
//            }
//        })
    }
}

extension RenewRetentionManager {
    
    // 获取会员剩余时间
    private class var remainTime: Double {
        
        guard !GLMPAccount.isFakeVip() else {
            return 0  // 排除善意假定
        }

        guard GLMPAccount.isVip(),
              let vipInfo = GLMPAccount.getVipInfo(),
              let expiredAt = vipInfo.expiredAt?.doubleValue else {
            return 0  // VIP用户
        }
    
        return expiredAt - Date().timeIntervalSince1970
    }
    
    private static let oneDay: Double = 24 * 3600 // 一天时间戳
    
    // 优惠活动时间限制
    class var limitTime: Double {
        let storeLimitTime = GLCache.double(forKey: activityLimitTimeKey)
        if storeLimitTime != 0 {
            return (storeLimitTime == -1 ? 0 : storeLimitTime)
        }
        let newRemainTime = remainTime
        var dateTime: Double = 0;
        if newRemainTime <= oneDay {
            dateTime = 0
        } else if newRemainTime > oneDay && newRemainTime <= oneDay * 3 {
            dateTime = oneDay
        } else {
            dateTime = 3 * oneDay
        }
        
        GLCache.setDouble((dateTime == 0 ? -1 : dateTime), forKey: activityLimitTimeKey)
        return dateTime
    }
    
        
    private static let activityLimitTimeKey: String = "userequity_activity_limit_time_store_key" // LimitTimeStoreKey
}




extension RenewRetentionManager {
    //MARK: - alert info
    class func showAlertInfo(from: String = "homeaddbenefits", complete: @escaping ((Bool) -> Void)) {
        guard let window = KeyWindow() else {
            complete(false)
            return;
        }
        let alertView = RenewRetentionConfirmView.init(frame: window.bounds, from: from)
        window.addSubview(alertView)
        alertView.showAnimation()
        alertView.closeClonse = {
            complete(true)
        }
        alertView.contactClonse = {
            complete(true)
            RenewRetentionManager.goToContactUsWithDefault(from: from)
        }
    }
    
    class func goToContactUsWithDefault(from: String) {
        //todo
//        guard let vc = ContactUsViewController.init(fromPage: from) else { return }
//        if !GL().Account_IsVip() {
//            vc.type = .NORMAL_SUPPORT
//        }
//        vc.tag = from
//        UIViewController.gl_top().navigationController?.pushViewController(vc, animated: true)
    }
}

extension RenewRetentionManager {
    
    class EquityItemModel: NSObject {
        var icon: String = ""
        var title: NSAttributedString?
        var desc: NSAttributedString?
    }
    
    class var userVipTimeText: (statrAt: String, expertAt: String) {
        guard let vipInfo = GL().Account_GetVipInfo(), let startAt = vipInfo.startAt?.doubleValue, let expiredAt = vipInfo.expiredAt?.doubleValue else {
            return ("", "")
        }
        let startDesc = NSDate.init(timeIntervalSince1970: startAt).gl_string(withFormat: "MMMM dd, yyyy")
        let expertDesc = NSDate.init(timeIntervalSince1970: expiredAt).gl_string(withFormat: "MMMM dd, yyyy")
        return (startDesc, expertDesc)
        
    }
    
    class var moreDayEquityModel: EquityItemModel {
        let model = EquityItemModel()
        model.icon = "equity_30_icon"
        
        let attr = RenewRetentionManager.createTitle(value: thirtyEquityText,
                                                        subValue: thirtySubEquityText)
        model.title = attr
        let mapTime = userVipTimeText
        let memberShipDesc = String(format: yourMembershipText, mapTime.expertAt)
        model.desc = RenewRetentionManager.createDesc(value: memberShipDesc)
        return model
    }
    
    class var askExpertModel: EquityItemModel {
        let model = EquityItemModel()
        model.icon = "equity_ask_icon"
        
        let attr = RenewRetentionManager.createTitle(value: askBotanistsText,
                                                        subValue: freeText)
        model.title = attr
        model.desc = RenewRetentionManager.createDesc(value: consultText)
        return model
    }
    
    class var bookModel: EquityItemModel {
        let model = EquityItemModel()
        model.icon = "equity_book_icon"
        
        let attr = RenewRetentionManager.createTitle(value: redeemText,
                                                        subValue: allFreeText)
        model.title = attr
        model.desc = RenewRetentionManager.createDesc(value: bookSubText)
        return model
    }
    
    //MARK: - action
    private class func createDesc(value: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle.gl_paragraphStyle(withLineHeight: GLFrameSize3(19, 19, 16, 15))
        return NSMutableAttributedString(string: value,
                                             attributes: [.font: UIFont.regular((IsIPad ? 16 : 14)),
                                                          .foregroundColor: UIColor.gl_color(0x999999),
                                                          .paragraphStyle: paragraphStyle])
    }
    
    private class func createTitle(value: String, subValue: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle.gl_paragraphStyle(withLineHeight: IsIPhone5 ? 18 : 24)
        let attr = NSMutableAttributedString(string: value,
                                             attributes: [.font: UIFont.semibold((IsIPad ? 18 : 16)),
                                                          .foregroundColor: UIColor.gl_color(0xffffff),
                                                          .paragraphStyle: paragraphStyle])
        
        let nsRange = (value as NSString).range(of: subValue)
        if nsRange.location != NSNotFound {
            attr.addAttributes([.font:  UIFont.semibold(16),
                                .foregroundColor: UIColor.gl_color(0x30C29A)],
                               range: nsRange)
        }
        
        return attr
    }
    
    //APP id 对应的符号
    private class var currencySymbol: String {
        guard let product = GL().Purchase_FetchAnyProductFromCache(),
                let symbol = product.priceLocale.currencySymbol,
                symbol.count > 0 else {
            return "$"
        }
        return symbol
    }
    
    //用户CurrentCode
    private class var specialSymbolCode: String {
        let countryCode = GLMPAppUtil.countryCode
       //法国，意大利、德国
        if countryCode == "FR" || countryCode == "IT" || countryCode == "DE" {
            return "€"
        }
        //英国
        if countryCode == "GB" {
            return "£"
        }
        // 其他美元符号
        return "$"
    }
    
    // 获取价格相关信息
    class func getVipInfo(complete:@escaping (_ expertAt: String, _ price: String) -> Void) {
        let expertAt = userVipTimeText.expertAt
        guard let userSku = userSku else {
            complete(expertAt, "?")
            return;
        }
        GL().Purchase_FetchProduct(userSku) { product in
            guard let product = product else {
                complete(expertAt, "?")
                return
            }
            let price = product.priceDescription(value: product.price.floatValue, maximumFractionDigits: 2)
            complete(expertAt, price)
        }
    }
    class func openSubscriptionAction() {
        var urlStr = GL().GLConfig_GetMainHost() + "/static/SubscriptionTerms_AppStore_20230220.html"
        if GLMPAppUtil.countryCode == "JP" {
            urlStr = "https://cms-cache.AINoteai.com/content/popular_search/config/SubscriptionTerms_AppStore_Japan_20230411.html"
        }
        if let url = URL.init(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
}

//MARK: - 多语言
extension RenewRetentionManager {
    static var thirtyEquityText: String {
        
        return GLMPLanguage.homepop_30day_title1
    }
    static var thirtySubEquityText: String {
        return GLMPLanguage.homepop_30day_title2
    }
    
    static var yourMembershipText: String {
        return GLMPLanguage.homepop_30day_content
    }
    
    static var askBotanistsText: String {
        return GLMPLanguage.homepop_experts_title1
    }
    
    static var freeText: String {
        return GLMPLanguage.homepop_botanists_title2
    }
    static var consultText: String {
        return GLMPLanguage.homepop_botanists_content1
    }
    
    static var redeemText: String {
        return GLMPLanguage.homepop_redeem_title1
    }
    static var allFreeText: String {
        return GLMPLanguage.homepop_redeem_title2
    }
    
    static var bookSubText: String {
        //homepop_redeem_content
        return GLMPLanguage.homepop_redeem_content
    }
    
    static var claimText: String {
        return GLMPLanguage.homepop_button1
    }
    
    static var noAdditionalText: String {
        //seasonpop_nopayment
        return GLMPLanguage.seasonpop_nopayment
    }
    static var giveUpText: String {
        return GLMPLanguage.homepop_button2
    }
    
    static var dearVIPText: String {
        return GLMPLanguage.homepop_dearvip
    }
    
    static var bottomDescText: String {
        return GLMPLanguage.homepop_note
    }
    
    static var confirmText: String {
        return GLMPLanguage.homepop_48hours
    }
    
    static var supportEmailText: String {
        return "support@AINoteai.com"
    }
}
