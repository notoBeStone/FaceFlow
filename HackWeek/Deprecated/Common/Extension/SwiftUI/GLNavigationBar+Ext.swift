//
//  GLNavigationBar+Ext.swift
//  AINote
//
//  Created by user on 2024/8/12.
//

import Foundation
import GLWidget
import SwiftUI
import GLResource
import GLUtils

extension GLNavigationBar {
    public func setBackLeadingItem(_ action: @escaping () -> Void) -> GLNavigationBar {
        return self.setLeadingImage("icon_back_outlined_regular", color: .g9, action: action)
    }
    
    public func setCloseLeadingItem(
        color: Color = .gW,
        shadow: GLShadowStyle? = nil,
        action: @escaping () -> Void
    ) -> GLNavigationBar {
        return self.setLeadingImage("icon_close_outlined_regular", color: color, shadow: shadow, action: action)
    }
    
    public func setBottomSheetCloseItem(action: @escaping () -> Void) -> GLNavigationBar {
        let copy = self.navigationBarItemsTrailing {
            Rectangle()
                .foregroundColor(.g0N)
                .frame(width: 32.rpx, height: 32.rpx)
                .background(
                    Image("icon_close_outlined_heavy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20.rpx, height: 20.rpx)
                        .foregroundColor(.g5N)
                )
                .clipShape(style: .circle)
                .controlSize(.large)
                .contentShape(Rectangle())
                .onTapGesture {
                    action()
                }
        }
        return copy
    }
    
    public func setLeadingImage(
        _ imageName: String,
        color: Color = .g9,
        circleBgColor: Color? = nil,
        shadow: GLShadowStyle? = nil,
        action: @escaping () -> Void
    ) -> GLNavigationBar {
        let iconWidth = circleBgColor != nil ? 20.rpx : 24.rpx
        let copy = self.navigationBarItemsLeading {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 32.rpx, height: 32.rpx)
                .background(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .flipsForRightToLeftLayoutDirection(GLDevice.isRTL())
                        .frame(width: iconWidth, height: iconWidth)
                        .foregroundColor(color)
                )
                .if(circleBgColor != nil) {
                    $0
                        .background(circleBgColor)
                        .clipShape(Circle())
                }
                .if(shadow != nil) {
                    $0
                        .gl_shadow(style: shadow ?? .sC)
                }
                .controlSize(.large)
                .contentShape(Rectangle())
                .onTapGesture {
                    action()
                }
        }
        return copy
    }
    
    public func setTrailingImage(_ imageName: String, color: Color = .g9, circleBgColor: Color? = nil, action: @escaping () -> Void) -> GLNavigationBar {
        let iconWidth = circleBgColor != nil ? 20.rpx : 24.rpx
        let copy = self.navigationBarItemsTrailing {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 32.rpx, height: 32.rpx)
                .background(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconWidth, height: iconWidth)
                        .foregroundColor(color)
                )
                .if(circleBgColor != nil) {
                    $0
                        .background(circleBgColor)
                        .clipShape(Circle())
                }
                .controlSize(.large)
                .contentShape(Rectangle())
                .onTapGesture {
                    action()
                }
        }
        return copy
    }
    
    //设置文本title
    public func setTitle(_ title: String, textColor: Color = .g9) -> GLNavigationBar {
        let copy = self.navigationBarTitleView {
            Text(title)
                .textStyle(.bodyMedium)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
        }
        return copy
    }
    
    
    //设置返回按钮和定位城市
    public func setLocationBackLeading(_ locationName: String, onLocationClick: @escaping () -> Void, onBackClick: @escaping () -> Void) -> GLNavigationBar {
        let copy = self.navigationBarItemsLeading {
            HStack(spacing: 8.rpx) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 32.rpx, height: 32.rpx)
                    .background(
                        Image("icon_back_outlined_regular")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .flipsForRightToLeftLayoutDirection(GLDevice.isRTL())
                            .frame(width: 20.rpx, height: 20.rpx)
                            .foregroundColor(.g9)
                    )
                    .controlSize(.large)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onBackClick()
                    }
                
                HStack(spacing: 8.rpx) {
                    Text(locationName)
                        .textStyle(.bodyMedium)
                        .foregroundColor(.g9)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Image("home_choose_angle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12.rpx, height: 12.rpx)
                        .shadow(color: Color(hex: 0x21A9FF, opacity: 0.2), radius: 4, y: 2)
                }
                
                .onTapGesture {
                    onLocationClick()
                }
            }
            .layoutPriority(1)
            
        }
        return copy
    }
    
    public func setMoreTrailingItem(_ action: @escaping () -> Void) -> GLNavigationBar {
        var copy = self.setTrailingImage("icon_more_outlined_regular", color: .g9) {
            action()
        }
        return copy
    }
}
