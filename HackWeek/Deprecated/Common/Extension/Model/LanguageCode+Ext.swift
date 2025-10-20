//
//  LanguageCode+Ext.swift
//  AINote
//
//  Created by Martin on 2024/11/12.
//

import Foundation
import DGMessageAPI
import GLResource

extension DGMessageAPI.LanguageCode {
    var title: String {
        let type = GLLanguageEnum(rawValue: self.rawValue) ?? .English
        return type.name
    }
    
    var nativeTitle: String {
        switch self {
        case .english:
            return "English"
        case .japanese:
            return "日本語"
        case .french:
            return "Français"
        case .arabic:
            return "العربية"
        case .spanish:
            return "Español"
        case .russian:
            return "Русский"
        case .portuguese:
            return "Português"
        case .german:
            return "Deutsch"
        case .italian:
            return "Italiano"
        case .chinese:
            return "中文"
        case .dutch:
            return "Nederlands"
        case .korean:
            return "한국어"
        case .swedish:
            return "Svenska"
        case .polish:
            return "Polski"
        case .traditionalChinese:
            return "繁體中文"
        case .malay:
            return "Bahasa Melayu"
        case .thai:
            return "ภาษาไทย"
        case .slovenia:
            return "Slovenščina"
        case .romanian:
            return "Română"
        case .indonesian:
            return "Bahasa Indonesia"
        case .galician:
            return "Galego"
        case .finnish:
            return "Suomi"
        case .norwegian:
            return "Norsk"
        case .danish:
            return "Dansk"
        case .turkish:
            return "Türkçe"
        case .greek:
            return "Ελληνικά"
        case .slovak:
            return "Slovenčina"
        case .czech:
            return "Čeština"
        case .persian:
            return "فارسی"
        case .catalan:
            return "Català"
        case .vietnamese:
            return "Tiếng Việt"
        case .hindi:
            return "हिंदी"
        case .hebrew:
            return "עברית"
        case .ukrainian:
            return "українська"
        case .urdu:
            return "اردو"
        case .marathi:
            return "मराठी"
        }
    }
    
    var event: String {
        switch self {
        case .english:
            return "english"
        case .japanese:
            return "japanese"
        case .french:
            return "french"
        case .arabic:
            return "arabic"
        case .spanish:
            return "spanish"
        case .russian:
            return "russian"
        case .portuguese:
            return "portuguese"
        case .german:
            return "german"
        case .italian:
            return "italian"
        case .chinese:
            return "chinese"
        case .dutch:
            return "dutch"
        case .korean:
            return "korean"
        case .swedish:
            return "swedish"
        case .polish:
            return "polish"
        case .traditionalChinese:
            return "traditionalChinese"
        case .malay:
            return "malay"
        case .thai:
            return "thai"
        case .slovenia:
            return "slovenia"
        case .romanian:
            return "romanian"
        case .indonesian:
            return "indonesian"
        case .galician:
            return "galician"
        case .finnish:
            return "finnish"
        case .norwegian:
            return "norwegian"
        case .danish:
            return "danish"
        case .turkish:
            return "turkish"
        case .greek:
            return "greek"
        case .slovak:
            return "slovak"
        case .czech:
            return "czech"
        case .persian:
            return "persian"
        case .catalan:
            return "catalan"
        case .vietnamese:
            return "vietnamese"
        case .hindi:
            return "hindi"
        case .hebrew:
            return "hebrew"
        case .ukrainian:
            return "ukrainian"
        case .urdu:
            return "urdu"
        case .marathi:
            return "marathi"
        }
    }
    
    var emoji: String? {
        switch self {
        case .english:
            return "🇺🇸"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        case .japanese:
            return "🇯🇵"
        case .chinese:
            return "🇨🇳"
        case .portuguese:
            return "🇧🇷"
        case .arabic:
            return "🇸🇦"
        case .russian:
            return "🇷🇺"
        case .italian:
            return "🇮🇹"
        case .german:
            return "🇩🇪"
        case .traditionalChinese:
            return "🇨🇳"
        case .korean:
            return "🇰🇷"
        case .thai:
            return "🇹🇭"
        case .malay:
            return "🇲🇾"
        case .vietnamese:
            return "🇻🇳"
        case .catalan:
            return nil
        case .czech:
            return "🇨🇿"
        case .galician:
            return "🇪🇸"
        case .greek:
            return "🇬🇷"
        case .persian:
            return "🇮🇷"
        case .romanian:
            return "🇷🇴"
        case .slovak:
            return "🇸🇰"
        case .slovenia:
            return "🇸🇮"
        case .swedish:
            return "🇸🇪"
        case .turkish:
            return "🇹🇷"
        case .danish:
            return "🇩🇰"
        case .dutch:
            return "🇳🇱"
        case .finnish:
            return "🇫🇮"
        case .hebrew:
            return "🇮🇱"
        case .hindi:
            return "🇮🇳"
        case .indonesian:
            return "🇮🇩"
        case .norwegian:
            return "🇳🇴"
        case .polish:
            return "🇵🇱"
        case .ukrainian:
            return "🇺🇦"
        case .urdu:
            return "🇵🇰"
        case .marathi:
            return "🇮🇳"
        }
    }
    
    static var all: [DGMessageAPI.LanguageCode] {
        let allLanguages: [LanguageCode] = [
            .english,
            .japanese,
            .french,
            .arabic,
            .spanish,
            .russian,
            .portuguese,
            .german,
            .italian,
            .chinese,
            .dutch,
            .korean,
            .swedish,
            .polish,
            .traditionalChinese,
            .malay,
            .thai,
            .slovenia,
            .romanian,
            .indonesian,
            .galician,
            .finnish,
            .norwegian,
            .danish,
            .turkish,
            .greek,
            .slovak,
            .czech,
            .persian,
            .catalan,
            .vietnamese,
            .hindi,
            .hebrew,
            .ukrainian,
            .urdu,
            .marathi
        ]
        return allLanguages
    }
    
    var nativeAndAppTitle: String {
        let nativeTitle = self.nativeTitle
        let appTitle = self.title
        
        if LanguageCode.current == self {
            return appTitle
        }
        return "\(appTitle) / \(nativeTitle)"
    }
}
