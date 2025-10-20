//
//  GLMPTracking.swift
//  AINote
//
//  Created by user on 2024/4/3.
//

import Foundation
import GLCore
import GLTrackingExtension
import GLAccountExtension

public class GLMPTracking {
    
    public class func tracking(_ event: String, parameters: [String : Any]? = nil) {
        GL().Tracking_Event(event, parameters: parameters)
    }
    
    public class func trackingError(_ error: String, mesasge: String) {
        GL().Tracking_Error(error, errorMessage: mesasge)
    }
    
    /// isDataCollectionDefaultEnabled
    /// 禁止收集数据（禁用期间，本地可缓存埋点，同意之后一起上报）
    public class func enableDataCollection(_ enable: Bool) {
        GL().Tracking_EnableDataCollection(enable)
    }
    
    
    /// 禁止收集数据（禁用期间，本地不可缓存埋点）
    public class func disableCookieControl(_ disable: Bool) {
        GL().Tracking_DisableCookieControl(disable)
    }
    
    /// 从server获取一个long id
    public class func getLongId(completion: ((NSNumber?) -> Void)?) {
        GL().Tracking_GetLongId(completion: completion)
    }
    
}

//MARK: - Launch
extension GLMPTracking {
    
    ///初始化， 内部调用GL().Tracking_Init()
    public class func setup() {
        if GL().Account_IsDeviceFirstLanuch() {
            GLMPTracking.appLaunch(isExistsUUIDInKeyChainStore: false)
        }
        
        GL().Tracking_Init()
    }
    
    public class func setUserId(_ userId: String) {
        GL().Tracking_SetUserID(userId)
    }
    
    
    public class func appLaunch(isExistsUUIDInKeyChainStore isExists: Bool) {
        GL().Tracking_AppLaunch(isExistsUUIDInKeyChainStore: isExists)
    }
}


//MARK: - Debugger
extension GLMPTracking {
    
    // debugger
    public class func registerDebugger() {
        GL().Tracking_RegisterDebugger()
    }
}
