//
//  GLConfig.swift
//  GLConfig
//
//  Created by xie.longyan on 2022/12/5.
//

import Foundation
import GLCore
import GLPurchaseExtension

/*
 项目配置说明
 
 GLConfig 包含项目所有通用配置
 GLOfflineServerConfig 包含项目所有离线配置 - 如果不需要离线模块，需在 Podfile 中去除 offlineserver 模块
 
 0.2产品参考配置文档
    - 《iOS 0.2产品接入指南》https://p0o4p0soey.feishu.cn/wiki/wikcnVZ46QX4k0NMKvCtUm697dd
    - 《iOS CI接入指南》https://p0o4p0soey.feishu.cn/wiki/wikcnqyuLKhFDbPeHN6IuPw3NGc
    - 《IOS 0.2 Template Excel》https://p0o4p0soey.feishu.cn/sheets/shtcnOk0QCpRxrIT4xvkR5gtNp2?sheet=0QKvDM
 */

@objc public enum AppEnv: Int, CaseIterable, Codable {
    case prod
    case stage
    case test
    
    /// 在 NetworkSignture 中需要配置
    /// 配置参考 https://p0o4p0soey.feishu.cn/wiki/wikcnqyuLKhFDbPeHN6IuPw3NGc
    var networkSignture: String {
        switch self {
        case .prod: return NetworkSignture.prod()
        case .stage:return NetworkSignture.stage()
        case .test: return NetworkSignture.test()
        }
    }
    
    public var mainHost: String {
        if let reviewAddress = reviewAddress {
            return reviewAddress
        }
        switch self {
            case .prod: return "https://app-service.faceflowbeauty.com"
            case .stage:
                return "https://app-service-stage.faceflowbeauty.com"
//                return "http://10.32.30.113:8070"
            case .test: return "https://app-service-stage.faceflowbeauty.com"
        }
    }
    
    //兼容老版本的测试reviewAddress
    private var reviewAddress: String? {
        guard self != .prod else {
            return nil
        }
        if let dict = UserDefaults.standard.object(forKey: "custom_server_url") as? [String: Any] {
            if let type = dict["type"] as? Int, let envType = AppEnv(rawValue: type), envType == self {
                if let url = dict["url"] as? String {
                    return url
                }
            }
        }
        return nil
    }
    
    var appHost: String {
        return mainHost + "/api"
    }
    
    var websiteHost: String {
        switch self {
        case .prod: return "https://pixelcell.com"
        case .stage:return "https://website-stage.pixelcell.com"
        case .test: return "https://website-stage.pixelcell.com"
        }
    }
    
    var abTestingHost: String {
        switch self {
        case .prod: return "https://gw.pixelcell.com/abtesting/api"
        case .stage:return "https://gw-stage.pixelcell.com/abtesting/api"
        case .test: return "https://gw-stage.pixelcell.com/abtesting/api"
        }
    }
    
    var trackingHost: String {
        switch self {
        case .prod: return "https://gw.pixelcell.com/tracking/api"
        case .stage:return "https://gw-stage.pixelcell.com/tracking/api"
        case .test: return "https://gw-stage.pixelcell.com/tracking/api"
        }
    }
    
    var trackingConfigHost: String {
        switch self {
        case .prod: return "https://gw.pixelcell.com/tracking-config/api"
        case .stage:return "https://gw-stage.pixelcell.com/tracking-config/api"
        case .test: return "https://gw-stage.pixelcell.com/tracking-config/api"
        }
    }
    
    /// `Optional`: 当 cloudUploaderNeedServerResize 为 `TRUE` 时，需要设置
    var awsS3Host: String {
        switch self {
        case .prod: return "https://gw.pixelcell.com/image-process/resize_and_save_to_s3"
        case .stage:return "https://gw-stage.pixelcell.com/image-process/resize_and_save_to_s3"
        case .test: return "https://gw-stage.pixelcell.com/image-process/resize_and_save_to_s3"
        }
    }
    
    /// `Optional`
    var cmsSearchHost: String {
        switch self {
        case .prod: return "https://cms-search-service.pixelcell.com/api"
        case .stage:return "https://cms-search-service-stage.pixelcell.com/api"
        case .test: return "https://cms-search-service-stage.pixelcell.com/api"
        }
    }
}


@objc public class GLConfig: NSObject {
    // AppConfig
    @objc dynamic public class var env: AppEnv { .stage }
    @objc public static let isSupportMultiLanguage: Bool = true // {$.is_support_multi_language}
        
    // AppInfo
    public static let appId: String = "6754315005"
    public static let teamId: String = "8DHYPVL45R"
    public static let appStoreLink = String(format: "https://apps.apple.com/app/id%@", appId)    // App Store Link
    public static let appStoreReviewLink = String(format: "itms-apps://itunes.apple.com/app/id%@?mt=8&action=write-review", appId)    // App Store Link
    public static let innerCode = "faceflow"
    public static let supportEmail = "support@thevisionext.com"
    public static let supportEmailScheme = "mailto:" + supportEmail
    public static let launchScreenCacheVersion = "0.1.0"    // 需要清理启动页缓存的版本
    
    // App Scheme
    public static let appScheme = "faceflow"
}

// MARK: - Tracking
extension GLConfig {
    static let appProductId: String = "faceflow"  // tcc name
}

// MARK: - Adjust
extension GLConfig {
    static let adjustAppToken: String = "yryvqdil0074"
    static let adjustTodayPayToken: String = "5x2xqt"
    static let adjustNPSToken: String = ""
    /// 返回是否需要客户端向 Adjust 上报订阅信息
    /// 如果需要客户端发送，则配置为 true；如果不需要，则配置为 false。
    static let adjustEnableTrackingSubscription: Bool = true // {$.adjust_enable_tracking_subscription} 客户端自行配置
}
