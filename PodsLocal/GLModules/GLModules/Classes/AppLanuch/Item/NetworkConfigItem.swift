//
//  NetworkConfigItem.swift
//  GLModules
//
//  Created by user on 2024/7/3.
//

import UIKit
import GLMP
import DGMessageAPI

public protocol NetworkHeaderConfigItemProtocol: WorkflowItem {
    static func requestHeaderHander(_ request: any APIEncodableRequest) -> [String: String]?
}

extension NetworkHeaderConfigItemProtocol {
    
    public func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        GLMPNetwork.requestAdditionalHeaderHandler = { request in
            return Self.requestHeaderHander(request)
        }
        completion(context)
    }
}

class NetworkHeaderConfigItem: NetworkHeaderConfigItemProtocol {
    
    static func requestHeaderHander(_ request: any APIEncodableRequest) -> [String: String]? {
        return nil
    }
}
