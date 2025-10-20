//
//  JSBridgeImplement+Business.swift
//  AINote
//
//  Created by 彭瑞淋 on 2024/10/18.
//

import Foundation
import GLWebView

extension RootJSBridgeImplement {
    
//    func handlerResultV5ClickReminder(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        
//        let params = invocation.invoke.params
//
//        guard let type = params?[ParamKeys.type]?.value as? String else {
//            return
//        }
//        
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? SnapHistoryDetailActionModel {
//            actionModel.addReminderAction.send(type)
//        }
//        
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? MyPlantDetailActionModel {
//            actionModel.addReminderAction.send(type)
//        }
//        
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? IdentifyResultActionModel {
//            actionModel.addReminderAction.send(type)
//        }
//        
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? PlantDetailActionModel {
//            actionModel.addReminderAction.send(type)
//        }
//        
//    }
//    
//    func handlerResultV5UpdateReminder(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        
//        let params = invocation.invoke.params
//        
//        guard let type = params?[ParamKeys.type]?.value as? String else {
//            return
//        }
//        
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? MyPlantDetailActionModel {
//            actionModel.updateReminderAction.send(type)
//        }
//    }
//    
//    func handlejumpWateringCalculator(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? MyPlantDetailActionModel {
//            actionModel.jumpToWateringCalculatorAction.send()
//        }
//    }
//    
//    func handlerJumpToRepottingChecker(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? MyPlantDetailActionModel {
//            actionModel.jumpToRepottingCheckerAction.send()
//        }
//    }
//    
//    func handlerResultV5OpenLightMeter(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? MyPlantDetailActionModel {
//            actionModel.jumpToLightAction.send()
//        }
//    }
//    
//    func handlerJumpExpertSupport(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? MyPlantDetailActionModel {
//            actionModel.jumpExpertSupportAction.send()
//        }
//    }
//    
//    func handlerResultV5JumpHealthCardImage(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? IdentifyResultActionModel {
//            actionModel.showHealthImageAction.send()
//        }
//    }
//    
//    func handlerCheckHealthStatus(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        
//        guard let status: String = invocation.getParam(ParamKeys.status) else {
//            return
//        }
//        
//        if let actionModel = invocation.webview?.delegate?.getActionModel() as? IdentifyResultActionModel {
//            actionModel.checkHealthStatusAction.send(status)
//        }
//    }
    
}
