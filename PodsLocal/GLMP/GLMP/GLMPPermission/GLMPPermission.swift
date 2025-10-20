//
//  GLMPPermission.swift
//  AINote
//
//  Created by user on 2024/4/12.
//

import Foundation
import AVFoundation
import Photos
import AppTrackingTransparency
import UserNotifications
import GLTrackingExtension

/// 用于管理 App 的权限，及权限请求
public class GLMPPermission {
}

// MARK: - 相机权限
extension GLMPPermission {
    
    public class func checkCameraPermission() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    /// 请求相机权限
    public class func requestCameraPermission(_ completion: @escaping (Bool) -> Void) {
        
        var notDetermined = false
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            notDetermined = true
        }
        
        guard notDetermined else {
            DispatchQueue.main.async {
                completion(AVCaptureDevice.authorizationStatus(for: .video) == .authorized)
            }
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if notDetermined {
                GLMPTracking.tracking("camera_permission_click", parameters: [GLT_PARAM_TYPE: granted ? "allow" : "not"])
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}


// MARK: - 相册权限
extension GLMPPermission {
    
    public class func checkSaveAblumPermission() -> Bool {
        PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized
    }
    
    /// 请求相册写入权限
    public class func requestSaveAblumPermission(_ completion: @escaping (Bool) -> Void) {
        
        var notDetermined = false
        if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .notDetermined {
            notDetermined = true
        }
        
        guard notDetermined else {
            DispatchQueue.main.async {
                completion(PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized)
            }
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            let granted = status == .authorized
            if notDetermined {
                GLMPTracking.tracking("album_permission_click", parameters: [GLT_PARAM_TYPE: granted ? "allow" : "not"])
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}


// MARK: - 推送权限
extension GLMPPermission {
    
    /// 判断是否有远程推送权限，有，返回true, 么有，返回false
    public class func checkPushNotificationPermission(_ completion: @escaping (Bool) -> Void) {
        getPushNotificationSettings { status in
            completion(status == .authorized)
        }
    }
    
    private class func getPushNotificationSettings(_ completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    private class func requestPushNotificationAuthorization(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                GLMPTracking.tracking("permission_push", parameters: [GLT_PARAM_TYPE: granted ? "allow" : "not"])
                completion(granted)
            }
        }
    }
    
    public class func requestPushNotificationPermission(_ completion: @escaping (Bool) -> Void) {
        getPushNotificationSettings { status in
            switch status {
            case .notDetermined:
                GLMPPermission.requestPushNotificationAuthorization(completion)
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        }
    }
}


// MARK: - ATT
extension GLMPPermission {
    
    /// 判断是否有App追踪权限，有，返回true, 么有，返回false
    public class func checkAppTrackingPermission() -> Bool {
        ATTrackingManager.trackingAuthorizationStatus == .authorized
    }
    
    /// 请求ATT权限
    public class func requestAppTrackingPermission(_ completion: @escaping (Bool) -> Void) {
        var notDetermined = false
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            notDetermined = true
        }
        
        guard notDetermined else {
            DispatchQueue.main.async {
                completion(ATTrackingManager.trackingAuthorizationStatus == .authorized)
            }
            return
        }
        
        GLMPTracking.tracking("app_tracking_permission_pop")
        ATTrackingManager.requestTrackingAuthorization { status in
            let granted = status == .authorized
            if notDetermined {
                GLMPTracking.tracking("app_tracking_permission_allow", parameters: [GLT_PARAM_TYPE: granted ? "1" : "0"])
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
