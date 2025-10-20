//
//  DeepLinks.swift
//  AINote
//
//  Created by user on 2024/6/19.
//

import Foundation
import AppModels
import GLMP
import GLConfig


class DeepLinks: GLMPRouterDataSource {
    static let shared = DeepLinks()
    
    private init() {
        GLMPRouter.setDataSource(self)
    }

    // MARK: - GLMPRouterDataSource
    func supportSchemes() -> [String] {
        return [GLConfig.appScheme, "https", "http"]
    }
    
    func supportHosts() -> [String] {
        return ["dl", "www.AINoteai.com"]
    }
    
    func getWapperNavigationController() -> UINavigationController.Type {
        return BaseNavigationViewController.self
    }
}


// MARK: - 构建业务跳转的DeepLink
extension DeepLinks {
    static func commonBottomSheetDialogWebViewDeepLink(from: String, pageName: String?, title: String?, url: String, startParams: [String: Any]? = nil) -> DeepLink {
        return DeepLink(
            path: DeepLinkPaths.commonBottomsheetwebview,
            from: from,
            params: [
                "pageName": pageName ,
                "title": title ,
                "url": url,
                "startParams": startParams
            ]
        )
    }
    
    static func settingsDeepLink(from: String) -> DeepLink {
        return DeepLink(path: DeepLinkPaths.settings, from: from)
    }
    
    static func contactUsDeepLink(from: String) -> DeepLink {
        return DeepLink(path: DeepLinkPaths.contactUs, from: from)
    }
}

