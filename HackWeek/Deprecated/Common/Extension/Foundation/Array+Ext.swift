//
//  Array+Ext.swift
//  AINote
//
//  Created by user on 2024/10/23.
//

import Foundation

extension Array {
    
    public func distinctBy<T: Hashable>(_ keyPath: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            let key = keyPath(element)
            return seen.insert(key).inserted
        }
    }
}

extension [String] {
    public func distinct() -> [String] {
        return distinctBy { $0 }
    }
}
