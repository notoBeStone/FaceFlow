//
//  UserTagsConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import AppConfig

class UserTagsConfigItem: WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        UserTagsConfig.setTags()
        completion(context)
    }
}
