//
//  SettingsCache.swift
//  AINote
//
//  Created by user on 2024/8/8.
//

import Foundation
import GLMP
import AppModels
import GLUtils

class SettingsCache {
    
    private static let KEY_ENABLE_AUTO_SAVE_TO_ALBUMS = "enableAutoSaveToAlbums"
    private static let KEY_SETTINGS_TEMPERATURE_UNIT_SETTING = "settingsTemperatureUnitSetting"
    private static let KEY_SETTINGS_MEASUREMENT_SYSTEM_SETTING = "settingsMeasurementSystemSetting"

    static var enableAutoSaveToAlbums: Bool {
        get {
            var enable: Bool = false
            let oldCacheKey = "kAutoSaveOffKey"
            if let oldCache = GLDefaults.object(forKey: oldCacheKey) as? NSNumber {
                enable = !oldCache.boolValue
                GLDefaults.removeObject(forKey: oldCacheKey)
                GLMPCache.set(key: KEY_ENABLE_AUTO_SAVE_TO_ALBUMS, value: enable)
                
            }
            enable = GLMPCache.get(key: KEY_ENABLE_AUTO_SAVE_TO_ALBUMS, default: false)
            return enable
        }
        set {
            GLMPCache.set(key: KEY_ENABLE_AUTO_SAVE_TO_ALBUMS, value: newValue)
        }
    }

    static var temperatureSetting: TemperatureUnit {
        get {
            let value: Int = GLMPCache.get(key: KEY_SETTINGS_TEMPERATURE_UNIT_SETTING, default: 0)
            return TemperatureUnit(rawValue: value) ?? .celsius
        }
        set {
            GLMPCache.set(key: KEY_SETTINGS_TEMPERATURE_UNIT_SETTING, value: newValue.rawValue)
        }
    }

    static var measurementSystemSetting: MeasurementSystem {
        get {
            let value: Int = GLMPCache.get(key: KEY_SETTINGS_MEASUREMENT_SYSTEM_SETTING, default: 0)
            return MeasurementSystem(rawValue: value) ?? .metric
        }
        set {
            GLMPCache.set(key: KEY_SETTINGS_MEASUREMENT_SYSTEM_SETTING, value: newValue.rawValue)
        }
    }
}
