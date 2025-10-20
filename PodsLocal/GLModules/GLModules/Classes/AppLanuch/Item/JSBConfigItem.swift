//
//  JSBConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLWebView
import GLCore
import GLConfig_Extension

public protocol JSBConfigItemProtocol: WorkflowItem {
    
    func getRegisterJSBImplements() -> [JSBImplement]
    func getAvailableDomains() -> [String]
    
}

public extension JSBConfigItemProtocol {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        H5Manager.shared.setup()
        
        let impList = getRegisterJSBImplements()
        if impList.count > 0 {
            impList.forEach { imp in
                H5Manager.shared.register(imp, for: type(of: imp).scope)
            }
        }

        // 线上非法域名，禁用jsbridge
        H5Manager.shared.verifyDomainAvailable = { host in
            let availableDomains = getAvailableDomains()
            if GL().GLConfig_currentEnvironmentIsProduction() {
                return availableDomains.first(where: { host.hasSuffix($0)}) != nil
            }
            return true
        }
        
        completion(context)
    }
    
}


class JSBConfigItem: JSBConfigItemProtocol {
    func getRegisterJSBImplements() -> [GLWebView.JSBImplement] {
        return []
    }
    
    func getAvailableDomains() -> [String] {
        return []
    }
}
