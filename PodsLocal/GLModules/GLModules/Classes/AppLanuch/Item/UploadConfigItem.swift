//
//  UploadConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLMP

class UploadConfigItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        GLMPUpload.updateCredentials()
        completion(context)
    }
    
    
}
