//
//  NPSConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLCore
import GLPopupExtension

public protocol NPSConfigItemProtocol: WorkflowItem {
    
    func getNpsExcludedClassList() -> [AnyClass]
    
    func getNpsExcludedClassNameList() -> [String]
    
}

extension NPSConfigItemProtocol {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        GL().Popup_NPSInit()
        
        GL().Popup_NPSAppendExcludedClass(anyClass: getNpsExcludedClassList(), className: getNpsExcludedClassNameList())
        
        completion(context)
    }
    
}


class NPSConfigItem: NPSConfigItemProtocol {
    func getNpsExcludedClassList() -> [AnyClass] {
        return []
    }
    
    func getNpsExcludedClassNameList() -> [String] {
        return []
    }
    

}
