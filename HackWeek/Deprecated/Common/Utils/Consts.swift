//
//  Consts.swift
//  AINote
//
//  Created by Martin on 2024/11/13.
//

import Foundation
import GLUtils
import GLCore
import GLAccountExtension
import SwiftUI
import GLResource
import GLMP

class Consts {
    static var contentLeading: Double {
        return 16.rpx
    }
    
    static var navContentHeight: Double {
        return Double(NavigationBarHeight)
    }
    
    static var safeTop: Double {
        if safeAreas.top == 0 {
            return 20.0
        } else {
            return safeAreas.top
        }
    }
    
    static var safeBottom: Double {
        return safeAreas.bottom
    }
    
    static var safeAreas: UIEdgeInsets = UIApplication.gl_safeAreaInsets()
    
    static var bgColor: Color {
        return Color.g0
    }
    
    static var textEditorInset: EdgeInsets {
        return .init(top: -8, leading: -5, bottom: -8, trailing: -5)
    }
}

func IsVIP() -> Bool {
    return GL().Account_IsVip()
}

typealias BoolCallback = (Bool)->()
typealias IntCallback = (Int)->()
typealias VoidCallback = ()->()
