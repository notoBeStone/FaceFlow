//
//  DeepLinks+Register.swift
//  AINote
//
//  Created by xie.longyan on 2024/6/19.
//

import Foundation
import GLMP
import GLWidget
import AppModels
import AppRepository

//MARK: - 注册Router path
extension DeepLinks {
    public func registerRouter() {
        //common webview
        GLMPRouter.register(DeepLinkPaths.commonBottomsheetwebview) { url, deeplink in
            guard let deeplink = deeplink else { return nil }
            return CommonWebViewController(deeplink: deeplink)
        }
        
        //settings
        GLMPRouter.register(DeepLinkPaths.settings) { url, deeplink in
            guard let deeplink = deeplink else { return nil }
            return SettingsViewController(deeplink: deeplink)
        }
        
        //ContactUs
        GLMPRouter.register(DeepLinkPaths.contactUs) { url, deeplink in
            guard let deeplink = deeplink else { return nil }
            
            return ContactUsViewController(deeplink: deeplink)
        }
        
        // MARK: - New Note
    }
}
