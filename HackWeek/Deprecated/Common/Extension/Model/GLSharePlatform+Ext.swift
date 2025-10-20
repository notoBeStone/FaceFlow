//
//  GLSharePlatform+Ext.swift
//  AINote
//
//  Created by user on 2024/8/12.
//

import Foundation
import GLShareExtension
import GLMP

extension GLSharePlatform {
    
    private var appUrlType: Int {
        var value = 0
        switch self {
        case .Whatsapp:
            value = 1
        case .Message:
            value = 5
        case .Mail:
            value = 4
        case .More:
            value = 6
        case .Twitter:
            value = 7
        case .Facebook:
            value = 8
        case .Print:
            break
        }
        return value
    }
    
    public func appInfo(url: String) -> (title: String?, content: String?, url: String?, image: UIImage?) {
        var title: String? = nil
        var content: String? = nil
        var appUrl: String? = nil
        var image: UIImage? = nil
        switch self {
        case .Whatsapp, .Facebook, .Twitter:
            title = GLMPLanguage.share_whatsapp_title
            appUrl = getAppUrl(url)
        case .Message:
            content = systemContent(url)
        case .Mail:
            title = GLMPLanguage.share_mail_title
            content = systemContent(url)
        case .More:
            image = UIImage(named: "pic_share")
            content = GLMPLanguage.share_mail_content
        case .Print:
            break
        }
        return (title, content, appUrl, image)
    }
    
    
    private func getAppUrl(_ url: String) -> String {
        var sendUrl = url
        if self == .Message {
            sendUrl = sendUrl.replacingOccurrences(of: "&reg", with: "&ampreg")
        }
        sendUrl = "\(sendUrl)&plant_type=\(appUrlType)"
        return sendUrl
    }
    
    private func systemContent(_ url: String) -> String {
        let content = GLMPLanguage.share_mail_content
        let name = GLMPAppUtil.appName
        let sendUrl = getAppUrl(url)
        return "\(content)\n\(name):\n\(sendUrl)"
    }
    
}
