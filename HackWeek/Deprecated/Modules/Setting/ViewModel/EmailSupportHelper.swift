//
//  Email.swift
//  Bible
//
//  Created by xie.longyan on 2023/12/19.
//

import Foundation
import GLCore
import GLAccountExtension
import GLUtils
import GLConfig
import DGMessageAPI
import AppModels

class EmailSupportHelper {
    static func openSupportEmail() {
        let bodyString = GLMPLanguage.text_share_email_body_template.gl_format(GL().Account_GetUserId() ?? "", GLDevice.deviceInformation(), "\(LanguageCode.current.rawValue)")
        var urlString = String(format: "%@?body=\n\n\n\n\n\n%@", GLConfig.supportEmailScheme, bodyString)
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: urlString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIPasteboard.general.string = GLConfig.supportEmail
        }
    }
}
