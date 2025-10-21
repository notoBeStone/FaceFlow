//
//  Font+App.swift
//  AINote
//
//  Created by user on 2024/3/26.
//

import UIKit
import GLUtils
import SwiftUI

import GLResource
import GLUtils

import GLResource
import GLUtils

extension Font {
    public static let avenirBody2Roman = Font.custom("Avenir-Roman", size: 14.rpx)
    public static let avenirBody2Medium = Font.custom("Avenir-Medium", size: 14.rpx)
    public static let avenirBodyHeavy = Font.custom("Avenir-Heavy", size: 16.rpx)
    public static let avenirBodyMedium = Font.custom("Avenir-Medium", size: 16.rpx)
    public static let avenirBodyRoman = Font.custom("Avenir-Roman", size: 16.rpx)
    public static let avenirButton1Medium = Font.custom("Avenir-Medium", size: 20.rpx)
    public static let avenirButton2Medium = Font.custom("Avenir-Medium", size: 16.rpx)
    public static let avenirButton3Medium = Font.custom("Avenir-Medium", size: 14.rpx)
    public static let avenirHeadlineBlack = Font.custom("Avenir-Black", size: 20.rpx)
    public static let avenirTabBarMedium = Font.custom("Avenir-Medium", size: 12.rpx)
    public static let avenirTabBarRoman = Font.custom("Avenir-Roman", size: 12.rpx)
    public static let avenirTitle1BlackOblique = Font.custom("Avenir-BlackOblique", size: 18.rpx)
    public static let avenirTitle1Heavy = Font.custom("Avenir-Heavy", size: 18.rpx)
    public static let avenirTitle1Medium = Font.custom("Avenir-Medium", size: 18.rpx)
    public static let avenirTitle2Heavy = Font.custom("Avenir-Heavy", size: 20.rpx)
    public static let avenirTitle2Medium = Font.custom("Avenir-Medium", size: 20.rpx)
    public static let avenirTitle3Heavy = Font.custom("Avenir-Heavy", size: 22.rpx)
    public static let avenirTitle3Medium = Font.custom("Avenir-Medium", size: 22.rpx)
    public static let avenirTitle4Heavy = Font.custom("Avenir-Heavy", size: 24.rpx)
    public static let avenirTitle5Heavy = Font.custom("Avenir-Heavy", size: 26.rpx)
    public static let avenirTitle6Heavy = Font.custom("Avenir-Heavy", size: 36.rpx)
}

extension UIFont {
    public static let avenirBody2Roman = UIFont.custom("Avenir-Roman", size: 14.rpx)
    public static let avenirBody2Medium = UIFont.custom("Avenir-Medium", size: 14.rpx)
    public static let avenirBodyHeavy = UIFont.custom("Avenir-Heavy", size: 16.rpx)
    public static let avenirBodyMedium = UIFont.custom("Avenir-Medium", size: 16.rpx)
    public static let avenirBodyRoman = UIFont.custom("Avenir-Roman", size: 16.rpx)
    public static let avenirButton1Medium = UIFont.custom("Avenir-Medium", size: 20.rpx)
    public static let avenirButton2Medium = UIFont.custom("Avenir-Medium", size: 16.rpx)
    public static let avenirButton3Medium = UIFont.custom("Avenir-Medium", size: 14.rpx)
    public static let avenirHeadlineBlack = UIFont.custom("Avenir-Black", size: 20.rpx)
    public static let avenirTabBarMedium = UIFont.custom("Avenir-Medium", size: 12.rpx)
    public static let avenirTabBarRoman = UIFont.custom("Avenir-Roman", size: 12.rpx)
    public static let avenirTitle1BlackOblique = UIFont.custom("Avenir-BlackOblique", size: 18.rpx)
    public static let avenirTitle1Heavy = UIFont.custom("Avenir-Heavy", size: 18.rpx)
    public static let avenirTitle1Medium = UIFont.custom("Avenir-Medium", size: 18.rpx)
    public static let avenirTitle2Heavy = UIFont.custom("Avenir-Heavy", size: 20.rpx)
    public static let avenirTitle2Medium = UIFont.custom("Avenir-Medium", size: 20.rpx)
    public static let avenirTitle3Heavy = UIFont.custom("Avenir-Heavy", size: 22.rpx)
    public static let avenirTitle3Medium = UIFont.custom("Avenir-Medium", size: 22.rpx)
    public static let avenirTitle4Heavy = UIFont.custom("Avenir-Heavy", size: 24.rpx)
    public static let avenirTitle5Heavy = UIFont.custom("Avenir-Heavy", size: 26.rpx)
    public static let avenirTitle6Heavy = UIFont.custom("Avenir-Heavy", size: 36.rpx)
}

extension UIFont {
    static func custom(_ name: String, size: Double) -> UIFont {
        .init(name: name, size: size) ?? .regular(size)
    }
}

extension Font {
    static func monserrat(_ size: CGFloat) -> Font {
        return .custom("Montserrat-Regular", size: size)
    }
    
    static func monserratMedium(_ size: CGFloat) -> Font {
        return .custom("Montserrat-Medium", size: size)
    }

    static func monserratBold(_ size: CGFloat) -> Font {
        .custom("Montserrat-Bold", size: size)
    }

    static func monserratSemiBold(_ size: CGFloat) -> Font {
        .custom("Montserrat-SemiBold", size: size)
    }
}
