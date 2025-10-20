//
//  DebuggerConfig.swift
//  GLModules
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLCore
import GLMP
import AppDebuggerExtension
import GLDebuggerExtension


class DebuggerConfigItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        
        GLMPTracking.registerDebugger()
        GLMPABTesting.registerDebugger()
        
        GL().AppDebugger_RegisterDebugger()
        
        GL().Debugger_Start()
        
        completion(context)
    }
    
}
