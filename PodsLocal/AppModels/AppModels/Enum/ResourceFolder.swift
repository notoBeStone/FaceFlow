//
//  ResourceFolder.swift
//  AppRepository
//
//  Created by Martin on 2024/11/14.
//

import Foundation

public enum ResourceStage {
    case temp
    case result
    
    public var name: String {
        switch self {
        case .temp:
            return "temp"
        case .result:
            return "result"
        }
    }
}

public enum ResourceType {
    case audio
    
    public var name: String {
        return "audio"
    }
}
