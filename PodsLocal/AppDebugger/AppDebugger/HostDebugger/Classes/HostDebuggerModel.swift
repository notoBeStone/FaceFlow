//
//  HostDebuggerModel.swift
//  AppDebugger
//
//  Created by xie.longyan on 2022/11/17.
//

import Foundation
import GLConfig

enum HostDebuggerModelType: Int, Codable {
    case config
    case custom
}

@objc public class HostDebuggerModel: NSObject, Codable {
    var type: HostDebuggerModelType
    @objc public var env: AppEnv
    var title: String
    @objc public var host: String
    
    var isSelected: Bool = false
    
    var info: String {
        return String(format: "%@: %@", self.title, self.host)
    }
    
    init(type: HostDebuggerModelType, title: String, host: String, env: AppEnv) {
        self.type = type
        self.title = title
        self.host = host
        self.env = env
    }
}
