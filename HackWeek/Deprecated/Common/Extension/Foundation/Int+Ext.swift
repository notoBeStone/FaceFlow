//
//  Int+Ext.swift
//  AINote
//
//  Created by xie.longyan on 2024/9/19.
//

import Foundation

extension Int {
    func toFloat() -> Float {
        return Float(self)
    }
    
    func toString() -> String {
        return "\(self)"
    }
    
    var character: Character {
        return Character(UnicodeScalar(self)!)
    }
    
    var hmsText: String {
        return String(format: "%d:%02d:%02d", self/3600, (self % 3600)/60, self % 60)
    }
    
    var msText: String {
        return String(format: "%d:%02d", self / 60, self % 60)
    }
    
    var date: Date {
        Date(timeIntervalSince1970: Double(self))
    }
}

extension Int64 {
    func toFloat() -> Float {
        return Float(self)
    }
    
    func toString() -> String {
        return "\(self)"
    }
    
    var date: Date {
        Date(timeIntervalSince1970: Double(self))
    }
}
