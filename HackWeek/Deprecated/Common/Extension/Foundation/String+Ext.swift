//
//  String+Ext.swift
//  IOSProject
//
//  Created by Martin on 2024/11/12.
//

import Foundation
import GLUtils

extension String {
    var uniqueFileName: String {
        let name = (self as NSString).gl_md5()
        let format = (self as NSString).pathComponents.last?.components(separatedBy: ".").last
        
        if let format = format, !format.isEmpty {
            return "\(name).\(format)"
        } else {
            return name
        }
    }
    
    static func uuid() -> String {
        let timestamp = Int(CFAbsoluteTimeGetCurrent() * 1000)
        return "\(timestamp)_\(arc4random() % 10000)"
    }
    
    func appendFile(component: String) -> String {
        return (self as NSString).appendingPathComponent(component)
    }
    
    func appendFile(components: [String]) -> String {
        var result = self
        components.forEach {
            result = result.appendFile(component: $0)
        }
        return result
    }
    
    var trimmingWhitespacesAndNewlines: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String {
    // 00:03.30 into TimeInterval
    func timeInterval() -> TimeInterval {
        let components = self.split(separator: ":")
        let minutes = TimeInterval(components[0]) ?? 0
        let seconds = TimeInterval(components[1]) ?? 0
        return minutes * 60 + seconds
    }
}
