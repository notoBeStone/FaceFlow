//
//  ScreenshoTrackingItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation

public protocol ScreenshotTrackingItemProtocol: WorkflowItem {
    func getScreenshotTrackingPramasHandler() -> ScreenshotTrackingParamsProtocol?
}

extension ScreenshotTrackingItemProtocol {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        ScreenshotTracking.shared.delegate = getScreenshotTrackingPramasHandler()
        completion(context)
    }
}


class DefaultScreenshoTrackingParamsItem: ScreenshotTrackingItemProtocol {
    func getScreenshotTrackingPramasHandler() -> ScreenshotTrackingParamsProtocol? {
        return nil
    }
}
