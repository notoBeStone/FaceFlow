//
//  AppUpgradeManager.swift
//  DangJi
//
//  Created by Martin on 2022/4/5.
//  Copyright © 2022 Glority. All rights reserved.
//

import UIKit
import GLComponentAPI
import GLCore
//import AppRepository
import GLResource
import GLMP
import GLUtils

@objc class AppUpgradeManager: NSObject {
    enum UpdateType {
        case none
        case must
        case should
    }
    @objc
    static var updateInfo: GLAPIAutoUpdate?
    
    @objc
    static func checkUpdate() -> Bool {
        guard let updateInfo = updateInfo else { return false }
        switch updateInfo.updateType {
        case .must:
            self.mustUpdate()
            return true
        case .should:
            self.shouldUpdatee()
            return false
        default:
            return false
        }
    }
    
    private static func mustUpdate() {
        DispatchMainAsync {
            update(force: true)
        }
        
    }
    
    private static func shouldUpdatee() {
        DispatchMainAsync {
            update(force: false)
        }
        
    }
    
    private static func update(force: Bool) {
        let title = GLModulesLanguage.text_warting_update
        let desc = force ? GLModulesLanguage.text_warning_update_old : GLModulesLanguage.text_warning_update_desc
        let alertView = AppUpgradeAlertView(title: title, description: desc, forced: force)
        alertView.showInView(nil, animated: true, completion: nil)
        
        alertView.closeHandler = { sender in
            sender.dismissAnimated(true, completion: nil)
        }
        
        alertView.confirmHandler = {
            guard let shareAppUrl = GLMPAccount.getClientConfig()?.shareAppUrl, let url = URL(string: shareAppUrl) else {
                return
            }
            UIApplication.shared.open(url, options: [.universalLinksOnly: false]) { success in
                if force {
                    exit(0)
                }
            }
        }
    }
}

fileprivate extension GLAPIAutoUpdate {
    var updateType: AppUpgradeManager.UpdateType {
        if let forceUpdate = forceUpdate, forceUpdate.boolValue {
            return .must
        }
        if let hasUpdate = hasUpdate, hasUpdate.boolValue {
            return .should
        }
        return .none
    }
}
