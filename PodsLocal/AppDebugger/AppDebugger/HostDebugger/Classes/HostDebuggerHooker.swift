//
//  HostDebuggerHooker.swift
//  AppDebugger
//
//  Created by xie.longyan on 2023/8/1.
//

import Foundation
import GLConfig

extension GLConfig {

    @objc dynamic public class var debugger_env: AppEnv {
        if let env = AppServerHostDebugger.env {
            return env
        }
        return self.debugger_env
    }
}
