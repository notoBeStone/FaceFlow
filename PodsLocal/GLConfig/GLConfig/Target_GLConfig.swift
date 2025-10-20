//
//  Target_GLConfig.swift
//  GLConfig
//
//  Created by User on 2020/11/13.
//

import Foundation

@objc public class Target_GLConfig : NSObject {
    
    // MARK: - APP ENV
    @objc public func Action_CurrentEnvironmentIsProduction(_ params: Dictionary<String, Any>) -> Bool {
        return GLConfig.env == .prod
    }
    
    @objc public func Action_CurrentEnvironmentIsStage(_ params: Dictionary<String, Any>) -> Bool {
        return GLConfig.env == .stage
    }

    @objc public func Action_UseHttps(_ params: Dictionary<String, Any>) -> Bool {
        return GLConfig.env == .prod || GLConfig.env == .stage
    }

    @objc public func Action_GetSignatureKey(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.networkSignture
    }
    
    @objc public func Action_GetMainHost(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.mainHost
    }
    
    @objc public func Action_GetServerAddress(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.appHost
    }
    
    @objc public func Action_GetWebsiteHost(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.websiteHost
    }
    
    // MARK: - ABTesting
    @objc public func Action_GetABTestAddress(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.abTestingHost
    }
    
    // MARK: - Tracking
    @objc public func Action_GetDataReceiverProductId(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.appProductId
    }
    
    @objc public func Action_GetTrackingServerAddress(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.trackingHost
    }

    @objc public func Action_GetTrackingConfigServerAddress(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.trackingConfigHost
    }

    // MARK: - Uploader
    @objc public func Action_GetAwsUploaderServerAddress(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.awsS3Host
    }

    // MARK: - CMSSearch
    @objc public func Action_GetCMSSearchServerAddress(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.env.cmsSearchHost
    }
    
    // MARK: - AppInfo
    @objc public func Action_GetAppId(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.appId
    }
    
    @objc public func Action_GetAppleTeamId(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.teamId
    }

    // MARK: - Adjust
    /// Config Document: https://p0o4p0soey.feishu.cn/wiki/wikcnhFT0xk7OUVBa578qgmoeNc
    /// Get `Adjust App Token`
    @objc public func Action_GetAdjustAppToken(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.adjustAppToken
    }
    
    /// Get `Adjust TodayPay Token`
    @objc public func Action_GetAdjustTodayPayToken(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.adjustTodayPayToken
    }
    
    @objc public func Action_GetAdjustNPSToken(_ params: Dictionary<String, Any>) -> String {
        return GLConfig.adjustNPSToken
    }
    
    /// 返回是否需要客户端向 Adjust 上报订阅信息
    /// 如果需要客户端发送，则配置为 true；如果不需要，则配置为 false。
    @objc public func Action_GetAdjustEnableTrackingSubscription() -> Bool {
        return GLConfig.adjustEnableTrackingSubscription
    }
    
    /// 设置 adjust 需要把数据放国外还是国内
    @objc public func Action_GetAdjustDataUrlType(_ params: Dictionary<String, Any>) -> Int {
        return 0
    }
    
    /// {$.device_id} 有些需要使用 FCUUID 配置 device_id 的项目，请自行配置，不需要贼直接删除该行
}
