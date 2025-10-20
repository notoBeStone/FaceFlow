//
//  GLMPAccount.swift
//  AINote
//
//  Created by user on 2024/4/2.
//

import Foundation
import GLCore
import GLUtils
import GLAccountExtension
import GLComponentAPI
import GLResource

public class GLMPAccount {
    
    public static let kPasswordMinLength: Int = 6
    
    @objc public enum GLAccountError: Int {
        case noError = 0
        case authorizationError = 1009
    }
    
    //MARK: - Get
    public class func getDeviceId() -> String? {
        GL().Account_GetDeviceId()
    }
    
    public class func getUserId() -> String? {
        GL().Account_GetUserId()
    }
    
    public class func getAccessToken() -> String? {
        GL().Account_GetAccessToken()
    }
    
    public class func getUser() -> GLAPIUser? {
        GL().Account_GetUser()
    }
    
    public class func getUserAdditionalData() -> GLAPIUserAdditionalData? {
        GL().Account_GetUserAdditionalData()
    }
    
    public class func vipLevel() -> GLVipLevel {
        getVipInfo()?.vipLevel ?? .NONE
    }
    
    public class func getVipInfo() -> GLAPIVipInfo? {
        GL().Account_GetVipInfo()
    }
    
    public class func getOtherConfigs() -> NSDictionary? {
        GL().Account_GetOtherConfigs()
    }
    
    public class func isVip() -> Bool {
        GL().Account_IsVip()
    }
    
    // unless you need to know the user is the fakevip, please use isVip
    public class func isFakeVip() -> Bool {
        GL().Account_IsFakeVip()
    }
    
    public class func isTrial() -> Bool {
        getVipInfo()?.isTrial == true
    }
    
    public class func getClientConfig() -> GLAPIClientConfig? {
        GL().Account_GetClientConfig()
    }
    
    ///  创建一小时内的用户,如果本地user为空则返回true
    public class func isNewUser() -> Bool {
        GL().Account_IsNewUser()
    }
    
    /// 判断当前设备是否第一次启动, 用于判断新设备第一次下载安装
    public class func isDeviceFirstLanuch() -> Bool {
        GL().Account_IsDeviceFirstLanuch()
    }
    
    public class func getServerTime() -> NSNumber? {
        GL().Account_GetServerTime()
    }
    
    public class func isUserCreateGreaterOrEauqlThan(_ version: String) -> Bool {
        guard let initVersion = GLMPAccount.getUser()?.appInitVersion else { return false }
        return initVersion.version >= version.version
    }

    public class func isUserCreateGreaterThan(_ version: String) -> Bool {
        guard let initVersion = GLMPAccount.getUser()?.appInitVersion else { return false }
        return initVersion.version > version.version
    }
    
    
    //MARK: - Set
    
    public class func setAccessToken(_ accessToken: String?) {
        GL().Account_SetAccessToken(accessToken)
    }
    
    public class func setUser(_ user: GLAPIUser?, userAdditionalData: GLAPIUserAdditionalData? = nil) {
        GL().Account_SetUser(user, userAdditionalData: userAdditionalData)
    }
    
    public class func setVipInfo(_ vipInfo: GLAPIVipInfo) {
        GL().Account_SetVipInfo(vipInfo)
    }
    
    
}

//MARK: - Network
extension GLMPAccount {
    
    public class func loadUserFromServer(completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_LoadUserFromServer(completion: completion)
    }
    
    public class func loadVipInfoFromServer(completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_LoadVipInfoFromServer(completion: completion)
    }
    
    public class func login(loginInfo: GLAPILoginInfo, loginAction: GLLoginAction, languageString:String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_Login(loginInfo: loginInfo, loginAction: loginAction, languageString: languageString, languageCode: languageCode, completion: completion)
    }
    
    public class func initialise(languageString:String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_Initialise(languageString: languageString, languageCode: languageCode, completion: completion)
    }
    
    public class func initialise(languageString:String, languageCode: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            GLMPAccount.initialise(languageString: languageString, languageCode: languageCode) { success, error in
                if let err = error {
                    continuation.resume(throwing: err)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    public class func getVerifyCode(email: String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_GetVerifyCode(email: email, languageCode: languageCode, completion: completion)
    }
    
    public class func checkVerifyCode(email: String, verifyCode: String, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_CheckVerifyCode(email: email, verifyCode: verifyCode, completion: completion)
    }
    
    public class func resetPasswordAndLogin(email: String, verifyCode: String, password: String, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_ResetPasswordAndLogin(email: email, verifyCode: verifyCode, password: password, completion: completion)
    }
    
    public class func deleteAccount(completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_DeleteAccount(completion: completion)
    }
    
    public class func getConfig(languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_GetConfig(languageCode: languageCode, completion: completion)
    }
    
    public class func updateAdditionalData(enableEmail: NSNumber?, growsPriceLabel: String?, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_UpdateAdditionalData(enableEmail: enableEmail, growsPriceLabel: growsPriceLabel, completion: completion)
    }
    
    public class func getFaq(languageCode: Int, completion: ((NSMutableArray?, NSError?) -> Void)? = nil) {
        GL().Account_GetFaq(languageCode: languageCode, completion: completion)
    }
    
    public class func updateDeviceInfo(languageString: String, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_UpdateDeviceInfo(languageString: languageString, completion: completion)
    }
    
    public class func updateProfile(nickname: String?, avatar: Data?, gender: Int, completion: ((String?, NSError?) -> Void)? = nil) {
        GL().Account_UpdateProfile(nickname: nickname, avatar: avatar, gender: gender, completion: completion)
    }
}


//MARK: - Combination of the API
extension GLMPAccount {
    
    public class func signupWithEmail(email: String, password: String, languageString:String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_SignupWithEmail(email: email, password: password, languageString: languageString, languageCode: languageCode, completion: completion)
    }
    
    public class func loginWithEmail(email: String, password: String, languageString:String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_LoginWithEmail(email: email, password: password, languageString: languageString, languageCode: languageCode, completion: completion)
    }
    
    
    public class func loginWithApple(user: String, mail: String, name: String, token: String, languageString:String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_LoginWithApple(user: user, mail: mail, name: name, token: token, languageString: languageString, languageCode: languageCode, completion: completion)
    }
    
    public class func restoreLogin(languageString:String, languageCode: Int, completion: ((Bool, NSError?) -> Void)? = nil) {
        GL().Account_RestoreLogin(languageString: languageString, languageCode: languageCode, completion: completion)
    }
}


//MARK: - For Debugger Use
extension GLMPAccount {
    
    public class func resetDeviceId() {
        GL().Account_ResetDeviceId()
    }
    
}



extension GLMPAccount {
    //用于更新用户信息和Vip信息
    public class func refreshUserAndVipInfo(completion: ((Bool, NSError?) -> Void)? = nil) {
        GLMPAccount.loadUserFromServer { success, error in
            if success == false {
                completion?(success, error)
                return
            }
            GLMPAccount.loadVipInfoFromServer(completion: completion)
        }
    }
}


extension GLMPAccount {
    
    ///原始初始化用户信息
    public class func userInitialise(completion: ((Bool) -> Void)? = nil) {
        let block: (Bool, NSError?) -> Void = { success, error in
            completion?(success)
        }
        GLMPTracking.tracking("initializeaccount_exposure")
        GLMPAccount.initialise(languageString: GLLanguage.currentLanguage.fullName, languageCode: GLLanguage.currentLanguage.languageId) { success, error in
            if let error = error {
                if error.serverErrorCode() == GLMPAccount.GLAccountError.authorizationError.rawValue {
                    GLMPTracking.tracking("initializeaccount_authorizationfailed_click")
                    GL().WebImage_ClearCache()
                    DispatchMainAsync {
                        NotificationCenter.default.post(name: .init(rawValue: GLMediator.kUserDeleteNotification), object: nil)
                        GLMPAccount.setAccessToken(nil)
                        GLMPAccount.initialise(languageString: GLLanguage.currentLanguage.fullName, languageCode: GLLanguage.currentLanguage.languageId, completion: block)
                    }
                } else {
                    GLMPTracking.tracking("initializeaccount_failed_click")
                    block(false, error)
                }
                return
            }
        
            block(success, error)
        }
        
    }
    
}


extension String {
    var version: Int {
        let subVersions = self.components(separatedBy: ".")
        let iVersions = subVersions.compactMap { subVersion in
            return Int(subVersion)
        }
        
        let versionText = iVersions.reduce(into: "") { partialResult, value in
            if partialResult.isEmpty {
                partialResult = "\(value)"
            } else {
                partialResult = partialResult + String(format: "%02d", value)
            }
        }
        return Int(versionText) ?? 0
    }
}
