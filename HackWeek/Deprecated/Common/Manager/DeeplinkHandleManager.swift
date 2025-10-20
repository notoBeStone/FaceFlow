//
//  DeeplinkHandleManager.swift
//  AINote
//
//  Created by 彭瑞淋 on 2024/10/30.
//

import Foundation
import GLMP

class DeeplinkHandleManager {
    static let shared = DeeplinkHandleManager()
    
    private var pendingDeepLink: DeepLink?
    private var isReady = false
    
    private init() {}
    
    
    func setReady(_ isReady: Bool) {
        self.isReady = isReady
        // 如果有待处理的 DeepLink 且 TabBar 已就绪，立即执行
        if isReady, let pendingLink = pendingDeepLink {
            executePendingDeepLink(pendingLink)
        }
    }
    
    // 处理 DeepLink
    private func handleDeepLink(_ deepLink: DeepLink) {
        if isReady {
            // TabBar 已就绪，直接执行
            GLMPRouter.open(deepLink)
        } else {
            // TabBar 未就绪，保存待执行
            pendingDeepLink = deepLink
        }
    }
    
    func handleUrl(_ url: URL) -> Bool {
        
//        // 检查是否是 widget scheme
//        let widgetSchemeUrl = URL(string: ReminderWidgetParameter.kReminderScheme)!
//        if url.scheme == widgetSchemeUrl.scheme && url.host == widgetSchemeUrl.host {
//            
//            let path = url.path
//            
//            var params: [String: Any] = [:]
//            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
//               let queryItems = components.queryItems {
//                for item in queryItems {
//                    params[item.name] = Int64(item.value ?? "") ?? item.value
//                }
//            }
//            
//            var openStyle: OpenStyle = .push
//            
//            if path == ReminderWidgetParameter.kReminderSnoozePath {
//                openStyle = .present
//            }
//            
//            let deeplink = DeepLink(path: path, from: TE.widget, params: params, openStyle: openStyle)
//            
//            self.handleDeepLink(deeplink)
//            return true
//        }
                
        return false
    }
    
    // 执行待处理的 DeepLink
    private func executePendingDeepLink(_ deepLink: DeepLink) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            GLMPRouter.open(deepLink)
        }
        pendingDeepLink = nil
    }
}

