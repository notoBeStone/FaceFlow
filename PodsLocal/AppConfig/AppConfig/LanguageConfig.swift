//
//  LanguageConfig.swift
//  AppConfig
//
//  Created by user on 2024/8/8.
//

import Foundation
import GLResource

public class LanguageConfig {
    
    public static var languages: [GLLanguageModel] {
        let suportLanguageCodes = ["en",
                                   "ja",
                                   "es",
                                   "fr",
                                   "de",
                                   "ru",
                                   "pt",
                                   "it",
                                   "ko",
                                   "tr",
                                   "nl",
                                   "ar",
                                   "th",
                                   "sv",
                                   "da",
                                   "pl",
                                   "fi",
                                   "el",
                                   "sk",
                                   "ms",
                                   "zh-Hant",
                                   "zh",
                                   "ca",
                                   "cs",
                                   "id",
                                   "nb"
        ]
        var suportLanguages = [GLLanguageModel]()
        for code in suportLanguageCodes {
            suportLanguages.append(
                GLLanguage.model(languageCode: code)
                ?? GLLanguageModel(id: 0, fullName: "", code: "", displayName: "")
            )
        }
        return suportLanguages
    }
    
}
