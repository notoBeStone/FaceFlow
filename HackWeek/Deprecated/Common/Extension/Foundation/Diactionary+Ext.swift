//
//  Diactionary+Ext.swift
//  IOSProject
//
//  Created by Martin on 2024/2/27.
//

import Foundation

extension Dictionary {
    func jsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error converting dictionary to JSON: \(error)")
            return nil
        }
    }
}

extension Dictionary where Key: Hashable {
    @discardableResult
    mutating func append(_ another: [Key: Value]) -> [Key: Value] {
        self.merge(another, uniquingKeysWith: { _, new in new })
        return self
    }
}
