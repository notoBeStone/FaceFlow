//
//  PaymentBarrierManager.swift
//  AINote
//
//  Created by user on 2024/6/7.
//

import UIKit
import GLDatabase
import GLMP

public class PaymentBarrierManager {
    
    private static let CacheKey = "PaymentBarrierManager_cacheKey"
    
    public class func isPaymentBarrier() -> Bool {
        guard let user = GLMPAccount.getUser() else {
            return false
        }
        return GLMPAccount.isVip() && (user.autoRenewStatus == .BILLING_RETRYING || user.autoRenewStatus == .BILLING_RETRY_FAIL)
    }
    
    public class func updatePaymentMethod() {
        if let url = URL(string: "https://apps.apple.com/account/billing") {
            UIApplication.shared.open(url)
        }
    }
    
    public class var expireInDay: Int {
        guard let value = GLMPAccount.getVipInfo()?.expiredAt?.doubleValue else {
            return 0
        }
        let expireDate = Date(timeIntervalSince1970: TimeInterval(value))
        let components = NSCalendar.current.dateComponents([.day, .hour], from: Date(), to: expireDate)
        var day = components.day ?? 0
        let hour = components.hour ?? 0
        if hour > 0 {
            day += 1
        }
        return day
    }
    
    public class func canShow() -> Bool {
        guard Self.isPaymentBarrier() else {
            return false
        }
        // 每天只出现一次
        if let date = GLCache.object(forKey: CacheKey) as? NSDate, date.gl_isToday() {
            return false
        }
        return true
    }
    
    class func showPopView(next: @escaping () -> Void) {
        GLCache.setObject(NSDate(), forKey: CacheKey)
        PaymentBarrierPopView.show(next: next)
    }
}
