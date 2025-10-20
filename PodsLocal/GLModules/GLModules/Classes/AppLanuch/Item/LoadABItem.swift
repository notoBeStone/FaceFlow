//
//  LoadABItem.swift
//  AINote
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLMP

class LoadABItem: WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        GLMPABTesting.loadABTesting { _, _ in
            completion(context)
        }
    }
}
