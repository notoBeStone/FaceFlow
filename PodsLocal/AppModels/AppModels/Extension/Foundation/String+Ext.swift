//
//  String+Ext.swift
//  AppModels
//
//  Created by user on 2024/8/1.
//

import Foundation
import GLUtils
import DGMessageAPI
import GLResource

extension String {
    
    /*
     将"yyyy-MM-dd"格式日期字符串转化为Date
     */
    public func yyyyMMddToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    public func toIntOrNil() -> Int? {
        return Int(self)
    }
    
    public func toDoubleOrNil() -> Double? {
        return Double(self)
    }
}



extension String {
    public func toMapMinAndMax() -> (min: Double, max: Double)? {
        //去除空格
        var result1 = NSString.init(string: self).replacingOccurrences(of: " ", with: "")
        //去掉单位
        result1 = NSString.init(string: result1).replacingOccurrences(of: "℃", with: "")
        let resultList = NSString.init(string: result1).components(separatedBy: "to")
        if resultList.count < 2 {
            return nil
        }
        guard let doubleValueMin = Double(resultList[0]) else {
            return nil
        }
        guard let doubleValueMax = Double(resultList[1]) else {
            return nil
        }
        if doubleValueMin > doubleValueMax {
            return nil
        }
        return (doubleValueMin, doubleValueMax)
    }
}

// MARK: - Path
extension String {
    public var uniqueFileName: String {
        let name = (self as NSString).gl_md5()
        let format = (self as NSString).pathComponents.last?.components(separatedBy: ".").last
        
        if let format = format, !format.isEmpty {
            return "\(name).\(format)"
        } else {
            return name
        }
    }
    
    public func appendFile(component: String) -> String {
        return (self as NSString).appendingPathComponent(component)
    }
    
    public func appendFile(components: [String]) -> String {
        var result = self
        components.forEach {
            result = result.appendFile(component: $0)
        }
        return result
    }
    
    public var document: String {
        GLSandBox.documentPath().appendFile(component: self)
    }
    
    public var noteAudioLocalPath: String {
        ResourceStage.result.name.appendFile(component: ResourceType.audio.name).appendFile(component: self.uniqueFileName).document
    }
}

extension String {
    public var languageCode: DGMessageAPI.LanguageCode {
        GLLanguageEnum.allCases.first {$0.code == self}?.languageCode ?? .english
    }
}

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
    public func toLongOrNil() -> Int64? {
        guard let value = self else {
            return nil
        }
        return Int64(value)
    }
    
    public func toIntOrNil() -> Int? {
        guard let value = self else {
            return nil
        }
        return Int(value)
    }
}
