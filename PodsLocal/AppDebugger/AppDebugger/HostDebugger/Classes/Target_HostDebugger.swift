//
//  Target_HostDebugger.swift
//  HostDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import GLDebugger
import GLUtils
import GLCore
import GLConfig_Extension

@objc public class Target_HostDebugger: NSObject {
    
    @objc func Action_RegisterDebugger(_ params: NSDictionary) {
        GLDebugger.registerPlugin(AppServerHostDebuggerPlugin())
    }
}
