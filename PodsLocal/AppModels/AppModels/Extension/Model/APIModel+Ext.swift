//
//  APIModel+Ext.swift
//  AINote
//
//  Created by 彭瑞淋 on 2024/7/17.
//

import Foundation
import DGMessageAPI

extension APIModel {
    
    public var jsonString: String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    public init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        guard let model = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = model
    }
}

extension MessageModel: Equatable {
    public static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}
