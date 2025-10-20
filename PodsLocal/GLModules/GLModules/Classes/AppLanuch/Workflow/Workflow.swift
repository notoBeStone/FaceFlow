//
//  Workflow.swift
//  AINote
//
//  Created by user on 2024/3/28.
//

import Foundation
import GLUtils

public protocol WorkflowItem {
    func execute(_ context: WorkflowContext, completion: @escaping (_ flowContext: WorkflowContext) -> Void)
}

public class WorkflowContext {
    public var interrupt: Bool = false
    public var params: [String: Any] = [:]
}

public class Workflow {
    
    private var workflowItems: [WorkflowItem] = []
    private var completionHandler: ((_ context: WorkflowContext) -> Void)?
    
    // 添加一个项到 workflow 中
    public func addItem(_ item: WorkflowItem) {
        workflowItems.append(item)
    }
    
    public func addItems(_ items: [WorkflowItem]) {
        workflowItems.append(contentsOf: items)
    }
    
    // 执行整个 workflow
    public func executeWorkflow(_ context: WorkflowContext? = nil, completion: @escaping (WorkflowContext) -> Void) {
        self.completionHandler = completion
        executeWorkflowItem(index: 0, context: context ?? WorkflowContext())
    }
    
    // 递归执行 workflow 中的项
    private func executeWorkflowItem(index: Int, context: WorkflowContext) {
        DispatchMainAsync { [weak self] in
            self?.handleWorkflowItem(index: index, context: context)
        }
    }
    
    private func handleWorkflowItem(index: Int, context: WorkflowContext) {
        
        guard index < workflowItems.count else {
            debugPrint("Workflow 执行完成.")
            completionHandler?(context)
            return
        }

        workflowItems[index].execute(context) { flowContext in
            if flowContext.interrupt == false {
                self.executeWorkflowItem(index: index + 1, context: flowContext)
            } else {
                debugPrint("Workflow 已被终止.")
                DispatchMainAsync { [weak self] in
                    self?.completionHandler?(flowContext)
                }
            }
        }
    }
}

/*
 * SubWorkflowItem
 */

public class SubWorkflowItem: WorkflowItem {
    
    private let subWorkflow: Workflow
    
    public convenience init(subItems: [WorkflowItem]) {
        let workflow = Workflow()
        workflow.addItems(subItems)
        self.init(subWorkflow: workflow)
    }
    
    public required init(subWorkflow: Workflow) {
        self.subWorkflow = subWorkflow
    }
    
    public func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        
        subWorkflow.executeWorkflow(context) { context in
            completion(context)
        }
    }
}
