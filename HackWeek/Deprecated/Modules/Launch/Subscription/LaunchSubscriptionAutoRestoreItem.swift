//
//  HomeLaunchAutoRestoreItem.swift
//  AINote
//
//  Created by user on 2024/5/30.
//

import UIKit
import GLCore
import GLUtils
import GLResource
import GLPurchaseUIExtension
import GLMP
import GLModules

class LaunchSubscriptionAutoRestoreItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        guard let window = KeyWindow(),
              GL().PurchaseUI_CanRestore() == .canRestore,
              !GLMPAccount.isVip() else {
            completion(context)
            return
        }

        let config = AutoRestoreConfig(logoImage: UIImage(named: "auto_restore_logo"),
                                       tintColor: .p5,
                                       loadingTitle: GLMPLanguage.autorestore_nodata_title_welcomebackto,
                                       loadingContent: GLMPLanguage.autorestore_nodata_text_wehavedetected,
                                       successfulTitle: GLMPLanguage.autorestore_nodata_title_enjoyexploringplants,
                                       failedTitle: GLMPLanguage.autorestore_nodata_title_restorefailed,
                                       failedContent: GLMPLanguage.autorestore_nodata_text_provideyouremail,
                                       invalidEmailToastContent: GLMPLanguage.text_invalid_email_address_content,
                                       languageCode: GLMPAppUtil.languageCode.rawValue,
                                       countryCode: GLMPAppUtil.countryCode)
        
        let restoreView = GL().PurchaseUI_GetAutoRestoreView(config: config) {
            context.interrupt = true
            completion(context)
        }
        
        if let restoreView = restoreView {
            window.addSubview(restoreView)
            restoreView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

}
