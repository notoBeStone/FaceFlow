//
//  TrackingConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLMP

class TrackingConfigItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        
        GLMPTracking.setup()
        
        completion(context)
    }
    
}
