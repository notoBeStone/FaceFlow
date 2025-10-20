//
//  GLMPNetworkError.swift
//  GLMP
//
//  Created by xie.longyan on 2024/5/29.
//

import Foundation

public enum GLMPNetworkError: Int {
    case invalidHost = -1
    case invalidParams = -2
    case parsingResponseFailed = -3
    
#warning("TODO - 本地化词条")
    private var message: String {
        switch self {
        case .invalidHost:
            return "Invalid Host"
        case .invalidParams:
            return "Invalid Params"
        case .parsingResponseFailed:
            return "Parsing Response Failed"
        }
    }
    
    public var error: Error {
        return NSError(domain: message, code: rawValue)
    }
}
