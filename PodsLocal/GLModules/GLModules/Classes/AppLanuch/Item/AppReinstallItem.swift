//
//  AppReinstallItem.swift
//  GLModules
//
//  Created by user on 2024/9/14.
//

import UIKit
import AppConfig

class AppReinstallItem: WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        Reinstall.shared.enter()
        completion(context)
    }
}
