//
//  Font+Extension.swift
//  KnitAI
//
//  Created by AI on 2024/03/21.
//

import SwiftUI

extension Font {
    // MARK: - Avenir Font Methods
    
    /// Returns an Avenir Light font with the specified size
    static func avenirLight(_ size: CGFloat) -> Font {
        .custom("Avenir-Light", size: size)
    }
    
    /// Returns an Avenir Regular font with the specified size
    static func avenirRegular(_ size: CGFloat) -> Font {
        .custom("Avenir-Roman", size: size)
    }
    
    /// Returns an Avenir Medium font with the specified size
    static func avenirMedium(_ size: CGFloat) -> Font {
        .custom("Avenir-Medium", size: size)
    }
    
    /// Returns an Avenir Bold font with the specified size
    static func avenirBold(_ size: CGFloat) -> Font {
        .custom("Avenir-Heavy", size: size)
    }
    
    /// Returns an Avenir Heavy font with the specified size
    static func avenirHeavy(_ size: CGFloat) -> Font {
        .custom("Avenir-Black", size: size)
    }
    
    /// Returns an Avenir Heavy Italic font with the specified size
    static func avenirHeavyItalic(_ size: CGFloat) -> Font {
        .custom("Avenir-BlackOblique", size: size)
    }
    
    // MARK: - Common Text Styles
    
    static func avenirTitle() -> Font {
        .avenirBold(24)
    }
    
    static func avenirHeadline() -> Font {
        .avenirMedium(17)
    }
    
    static func avenirBody() -> Font {
        .avenirRegular(16)
    }
    
    static func avenirCaption() -> Font {
        .avenirLight(12)
    }
}

// MARK: - Usage Example
/*
 Text("Hello World")
     .font(.avenirMedium(16))
 
 Text("Title")
     .font(.avenirTitle())
*/ 