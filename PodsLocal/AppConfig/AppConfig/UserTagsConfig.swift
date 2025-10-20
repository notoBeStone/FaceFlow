//
//  UserTagsConfig.swift
//  AINote
//
//  Created by Martin on 2023/6/9.
//

import Foundation
import GLCore
import GLABTestingExtension
import GLUserTag_Extension
import GLAccountExtension
import GLDatabase
import GLUtils

fileprivate extension String {
    static let lastLoginDays = "last_login_days" // 最后一次登录在几天前
    static let lastLoginHours = "last_login_hours" // 最后一次登录在几个小时前
    static let reinstall = "reinstall" // 是否为重新安装
    static let deviceVersion = "device_os_version" // 设备类型
    static let isInHistory = "is_vip_in_history" // 是否为历史vip
    static let IsTrailVip = "is_autoreview_trail_vip" //试用期未取订
    static let IsTrailVipCancelAutoReview = "is_cancel_autoreview_trail_vip" //试用期取订
    static let TRUE = "true"
    static let FALSE = "false"
}

public class UserTagsConfig {
    private static var lastLoginTime: Double? = nil
    
    public static func setTags() {
        GL().UserTag_Setup()
        GL().ABTesting_SetProjectPrivateTags {
            return UserTagsConfig.setOtherTags()
        }
    }
    
    private static func setOtherTags() -> [String: [String]] {
        var tags: [String: [String]] = [:]
        tags.gl_merge(self.tagLastLogin())
        tags.gl_merge([.reinstall: [Reinstall.shared.isReinstall ? .TRUE : .FALSE]])
        return tags
    }
    
    private static func tagLastLogin() -> [String: [String]] {
        let key = "lastlogintime"
        if lastLoginTime == nil {
            if !GLCache.contains(forKey: key) {
                lastLoginTime = GL().Account_GetUser()?.createdAt.doubleValue
            } else {
                lastLoginTime = GLCache.double(forKey: key)
            }
        }
        
        let currentTime = Date().timeIntervalSince1970
        GLCache.setDouble(currentTime, forKey: key)
        
        var days: Int
        var hours: Int
        if let lastLoginTime = lastLoginTime {
            let interval = Int(currentTime - lastLoginTime)
            days = interval / (3600 * 24)
            hours = interval / 3600
        } else {
            days = 100
            hours = 100 * 360 * 24
        }
        
        return [
            .lastLoginDays: ["\(days)"],
            .lastLoginHours: ["\(hours)"],
        ]
    }
    
    static func isTrailVipAutoReview() -> String {
        
        guard let vipInfo = GL().Account_GetVipInfo(), GL().Account_IsVip() else {
            return .FALSE
        }
        
        guard let isTrail = vipInfo.isTrial?.boolValue, isTrail else {
            return .FALSE
        }
        
        guard let isAutoRenew = vipInfo.isAutoRenew?.boolValue, isAutoRenew else {
            return .FALSE
        }
        
        return .TRUE
    }
    
    static func isTrailVipCancelAutoReview() -> String {
        guard let vipInfo = GL().Account_GetVipInfo(), GL().Account_IsVip() else {
            return .FALSE
        }
        guard let isTrail = vipInfo.isTrial?.boolValue,
                isTrail else {
            return .FALSE
        }
        guard let isAutoRenew = vipInfo.isAutoRenew?.boolValue, !isAutoRenew else {
            return .FALSE
        }
        return .TRUE
    }
}

public class Reinstall {
    public let isFirstIn: Bool
    private let firstEnterDataCache: GLModelCache<Date>
    public static let shared = Reinstall()
    
    private init() {
        let firstEnterDataCache = GLModelCache<Date>(key: "userFirstEnteredAppCacheKey", versionData: nil)
        self.isFirstIn = firstEnterDataCache.data == nil
        self.firstEnterDataCache = firstEnterDataCache
    }
    
    public var isReinstall: Bool {
        return self.isFirstIn && (GL().Account_GetUserAdditionalData()?.existUser.boolValue ?? false)
    }
    
    public var firstEnterDate: Date? {
        return self.firstEnterDataCache.data
    }
    
    public func enter() {
        if self.firstEnterDataCache.data == nil {
            self.firstEnterDataCache.data = Date()
        }
    }
}
