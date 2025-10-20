//
//  AppDebugger.swift
//  AppDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import GLCore

let kAppDebuggerModule = "AppDebugger"
let kHostDebuggerTarget = "HostDebugger"
let kCacheDebuggerTarget = "CacheDebugger"

public extension GLMediator {

    @objc func AppDebugger_RegisterDebugger() {
        let params: [AnyHashable : Any] = [kGLMediatorParamsKeySwiftTargetModuleName: kAppDebuggerModule]
        self.performTarget(kHostDebuggerTarget, action: "RegisterDebugger", params: params, shouldCacheTarget: false);
        self.performTarget(kCacheDebuggerTarget, action: "RegisterDebugger", params: params, shouldCacheTarget: false);
    }
    
    @objc func AppDebugger_BeautyEngineHost() -> String? {
        let params: [AnyHashable : Any] = [kGLMediatorParamsKeySwiftTargetModuleName: kAppDebuggerModule]
        return self.performTarget(kHostDebuggerTarget, action: "BeautyEngineHost", params: params, shouldCacheTarget: false) as? String;
    }
    
    @objc func AppDebugger_AppServerHost() -> String? {
        let params: [AnyHashable : Any] = [kGLMediatorParamsKeySwiftTargetModuleName: kAppDebuggerModule]
        return self.performTarget(kHostDebuggerTarget, action: "AppServerHost", params: params, shouldCacheTarget: false) as? String;
    }
}
