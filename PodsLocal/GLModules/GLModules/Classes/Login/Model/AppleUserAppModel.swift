//
//  AppleLoginManager.swift
//  Adjust
//
//  Created by user on 2024/8/15.
//

import Foundation

public enum AppleLoginStatus: Int {
    case `failed` = -1
    case success = 0
    case canceled = 1
}

public struct AppleUserAppModel {
    
    public let user: String
    public let name: String
    public let mail: String
    public let token: String
    
    
    public init(user: String, name: String, mail: String, token: String) {
        self.user = user
        self.name = name
        self.mail = mail
        self.token = token
    }
}
