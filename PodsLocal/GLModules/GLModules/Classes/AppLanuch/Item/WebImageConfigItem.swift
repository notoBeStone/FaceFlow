//
//  WebImageConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLCore
import GLUtils
import GLMP
import AppConfig
import GLWebImageExtension

class WebImageConfigItem: WorkflowItem {

    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        Self.configWebImage()
        completion(context)
    }
    
    private static func configWebImage() {
        
        GL().WebImage_SetDefaultPlaceholder(image: AppLaunchConfig.defaultPlaceholderImage,
                                            backgrouindColor: AppLaunchConfig.defaultPlaceholderBackgroundColor,
                                            contentMode: .center)
        GL().WebImage_SetMaxCachePeriod(AppLaunchConfig.imageMaxCachePeriod)
        
        //加签
        GL().WebImage_SetRequestModifier { request in
            var urlRequest = request
            if let userId = GLMPAccount.getUserId() {
                urlRequest.addValue("\(userId)", forHTTPHeaderField: "user-id")
            }
            
            if let accessToken = GLMPAccount.getAccessToken() {
                urlRequest.addValue(accessToken, forHTTPHeaderField: "access-token")
            }
            return urlRequest
        }
    }
}
