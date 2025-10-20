//
//  Float+Ext.swift
//  AINote
//
//  Created by xie.longyan on 2024/9/19.
//

import Foundation

extension Float {
    func roundToInt() -> Int {
        return Int(self.rounded())
    }
    
    func toInt() -> Int {
        return Int(self)
    }
}


extension Float {
    func coerceIn(_ minimumValue: Float, _ maximumValue: Float) -> Float {
        let minValue = min(minimumValue, maximumValue)
        let maxValue = max(minimumValue, maximumValue)
        if self < minValue {
            return minValue
        }
        if self > maxValue {
            return maxValue
        }
        return self
    }
}
