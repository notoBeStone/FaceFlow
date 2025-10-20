//
//  GLMPAgreement.swift
//  AINote
//
//  Created by user on 2024/4/8.
//

import AppTrackingTransparency
import Foundation
import GLAgreement_Extension
import GLCore
import GLTrackingExtension

public class GLMPAgreement {
    
    private static var useMemo: String = ""
    
    public static var hasAgreed: Bool {
        return GL().Agreement_IsAgreePrivacyPolicy()
    }
    
    //初始化组件
    public static func initAgreement(with memo: String = "Default") {
        GL().Agreement_Init()
        useMemo = memo
    }
    
    //检查用户协议
    public static func checkAgreement(_ completion: @escaping () -> Void) {
        GL().Agreement_SpecifiedOpen(group: useMemo, localAgreeVersion: nil) { currentVC, complete in
            complete()
        } emailLogin: { currentVC, complete in
            complete()
        } callback: { _ in
            GLMPPermission.requestAppTrackingPermission { _ in
                completion()
            }
        }
    }
    
    public static func openPrivacyPolicy(with vc: UIViewController) {
        GL().Agreement_OpenPrivacyPolicy(controller: vc)
    }
    
    public static func openTermsOfUse(with vc: UIViewController) {
        GL().Agreement_OpenCurrentTermsOfUse(controller: vc)
    }
}
