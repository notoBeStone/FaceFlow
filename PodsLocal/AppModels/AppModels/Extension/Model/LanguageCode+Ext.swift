//
//  LanguageCode+Ext.swift
//  AppRepository
//
//  Created by Martin on 2024/11/14.
//

import Foundation
import DGMessageAPI
import GLResource

public extension DGMessageAPI.LanguageCode {
    public var code: String {
        return GLLanguage.models(languageEnums: [self.languageEnum]).first?.code ?? GLLanguage.currentLanguage.code
    }
    
    public var languageEnum: GLLanguageEnum {
        return GLLanguageEnum(rawValue: self.rawValue) ?? .English
    }
    
    public static var current: DGMessageAPI.LanguageCode {
        GLLanguage.currentLanguage.code.languageCode
    }
}

public extension GLLanguageEnum {
    public var languageCode: LanguageCode {
        return LanguageCode(rawValue: self.rawValue) ?? .english
    }
    
    public var code: String {
        GLLanguage.models(languageEnums: [self]).first?.code ?? GLLanguage.currentLanguage.code
    }
}
