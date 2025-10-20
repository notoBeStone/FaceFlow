//
//  Double+Ext.swift
//  AINote
//
//  Created by xie.longyan on 2024/9/23.
//

import Foundation
import GLUtils

public extension Double {
    func roundToInt() -> Int {
        return Int(self.rounded())
    }
    
    var msText: String {
        return Int(self).msText
    }
    
    var hmsText: String {
        return Int(self).hmsText
    }
    
    var megabytes: Double {
        self / 1024.0 / 1024.0
    }
    
    static var now: Double {
        Date().timeIntervalSince1970
    }
    
    var date: Date {
        Date(timeIntervalSince1970: self)
    }
    
    var isToday: Bool {
        return (self.date as NSDate).gl_isToday()
    }
    
    func isSameDay(with another: Double) -> Bool {
        (self.date as NSDate).gl_is(sameDay: another.date)
    }
    
    func isSameDay(with another: Date) -> Bool {
        (self.date as NSDate).gl_is(sameDay: another)
    }
    
    func days(from another: Double) -> Int {
        (self.date as NSDate).gl_days(from: another.date)
    }
    
    var formatedTimeStr: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
