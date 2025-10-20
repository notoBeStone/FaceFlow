//
//  ABTestingManager.swift
//  AINote
//
//  Created by user on 2024/4/3.
//

import Foundation
import GLResource
import DGMessageAPI

public class GLMPAppUtil {
    
    
    /// Language Code
    public static var languageCode: LanguageCode {
        return LanguageCode(rawValue: GLLanguage.currentLanguage.languageId) ?? .english
    }
    
    /// Language Model
    public static var currentLanguage: GLLanguageModel {
        return GLLanguage.currentLanguage
    }
    
    ///  Country Code
    public static var countryCode: String {
        let local = NSLocale.current
        var code: String?
        if #available(iOS 16, *) {
            code = local.region?.identifier
        } else {
            code = local.regionCode
        }
        
        return code ?? "US"

    }
    
    
    /// 根据摄氏度获得温度的 string
    /// - Parameters:
    ///   - temperture: 温度
    ///   - fractionDigits: 小数点
    /// - Returns: 温度 string
    public static func getTempertureStringFromCentigrade(_ temperture: Double, fractionDigits: Int = 0) -> String {
        let mf = MeasurementFormatter()
        mf.unitOptions = .providedUnit
        mf.numberFormatter.maximumFractionDigits = fractionDigits
        let measurement = Measurement(value: temperture, unit: UnitTemperature.celsius)
        return mf.string(from: measurement)
    }
    
    
    public static func getTempertureStringFromCentigradeWithoutUnit(_ temperture: Double, fractionDigits: Int = 0) -> String {
        let mf = MeasurementFormatter()
        mf.unitOptions = .temperatureWithoutUnit
        mf.numberFormatter.maximumFractionDigits = fractionDigits
        let measurement = Measurement(value: temperture, unit: UnitTemperature.celsius)
        return mf.string(from: measurement)
    }
    
    /// 是否是摄氏度
    public static func isCentigrade() -> Bool {
        let temp = Self.getTempertureStringFromCentigrade(0)
        return temp.contains("°C")
    }
    
    public static func isCm() -> Bool {
        return Locale.current.usesMetricSystem
    }
    
    /// App version
    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    /// App Display Name
    public static var appName: String {
        if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return name
        }
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return ""
    }
    
    
    //将文件大小以String格式输出
    public static func stringFromSize(_ size: CGFloat) -> String {
        if size < 1000 {
            return String(format: "%.0fB", size)
        } else if size < 1_000 * 1024 {
            return String(format: "%.2fKB", size / 1024)
        } else if size < 1_000 * 1024 * 1024 {
            return String(format: "%.2fMB", size / (1024 * 1024))
        } else {
            return String(format: "%.2fGB", size / (1024 * 1024 * 1024))
        }
    }
    
}

