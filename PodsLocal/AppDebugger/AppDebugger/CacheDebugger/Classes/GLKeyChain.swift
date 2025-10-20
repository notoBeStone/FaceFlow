//
//  GLKeyChain.swift
//  AppDebugger
//
//  Created by xie.longyan on 2024/10/24.
//

import Foundation
import Security

struct GLKeyChain {
    
    static func removeAllItems() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        
        for secItemClass in secItemClasses {
            let query: [String: Any] = [kSecClass as String: secItemClass]
            SecItemDelete(query as CFDictionary)
        }
    }
}
