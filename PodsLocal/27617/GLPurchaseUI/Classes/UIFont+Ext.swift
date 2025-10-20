//
//  UIFont+Ext.swift
//  Vip27584
//
//  Created by Martin on 2024/12/4.
//

import UIKit
import GLUtils
import GLResource

extension UIFont {
    static let title2Bold = UIFont(name: "Montserrat-Bold", size: GLFrameSize1(34, 22.rpx)) ?? UIFont.heavy(GLFrameSize1(34, 22.rpx))
    static let bodyMedium = UIFont(name: "Avenir-Medium", size: 16.rpx) ?? UIFont.medium(16.rpx)
    static let body2Roman = UIFont(name: "Avenir-Roman", size: 14.rpx) ?? UIFont.bold(14.rpx)
    static let buttonTextMedium = UIFont(name: "Avenir-Medium", size: 14.rpx) ?? UIFont.medium(14.rpx)
    
    static func heavyAvenir(_ size: CGFloat)  -> UIFont { UIFont.init(name: "Montserrat-Bold", size: size) ?? .regular(size) }
    static func mediumAvenir(_ size: CGFloat)  -> UIFont { UIFont.init(name: "Montserrat-Medium", size: size) ?? .regular(size) }
    static func blackAvenir(_ size: CGFloat)  -> UIFont { UIFont.init(name: "Avenir-Black", size: size) ?? .regular(size) }
}
