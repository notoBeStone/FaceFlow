//
//  Wind.swift
//  KnitAI
//
//  Created by stephenwzl on 2025/3/28.
//

import SwiftUI
import GLWidget

extension Text {
    // font
    
    func fontRegular(_ size: CGFloat) -> Text {
        self.font(.monserrat(size))
    }
    
    func fontMedium(_ size: CGFloat) -> Text {
        self.font(.monserratMedium(size))
    }

    func fontSemiBold(_ size: CGFloat) -> Text {
        self.font(.monserratSemiBold(size))
    }

    func fontBold(_ size: CGFloat) -> Text {
        self.font(.monserratBold(size))
    }
    
    var title1Medium: Text {
        self.font(.avenirTitle1Medium)
    }
    var title1Heavy: Text {
        self.font(.avenirTitle1Heavy)
    }
    var title2Heavy: Text {
        self.font(.avenirTitle2Heavy)
    }
    var title3Heavy: Text {
        self.font(.avenirTitle3Heavy)
    }
    var title4Heavy: Text {
        self.font(.avenirTitle4Heavy)
    }
    
    var button1Medium: Text {
        self.font(.avenirButton1Medium)
    }
    var button2Medium: Text {
        self.font(.avenirButton2Medium)
    }
    
    var bodyMedium: Text {
        self.font(.avenirBodyMedium)
    }
    
    var bodyHeavy: Text {
        self.font(.avenirBodyHeavy)
    }
    
    // layout
    
    var blockLeading: some View {
        self.block()
    }
    
    var blockCenter: some View {
        self.block(.center, textAlignment: .center)
    }
    
    var blockTrailing: some View {
        self.block(.trailing, textAlignment: .trailing)
    }
    
    // color
    func color(_ color: Color) -> Text {
        self.foregroundColor(color)
    }
    
    var colorG9L: Self {
        self.color(.g9L)
    }
    
    var colorG8L: Self {
        self.color(.g8L)
    }
    
    var colorG6L: Self {
        self.color(.g6L)
    }
    
    var colorG4L: Self {
        self.color(.g4L)
    }

    var colorGWL: Self {
        self.color(.gwL)
    }
}

extension View {
    func pt(_ spacing: CGFloat) -> some View {
        self.padding(.top, spacing)
    }
    
    func pb(_ spacing: CGFloat) -> some View {
        self.padding(.bottom, spacing)
    }
    
    func pl(_ spacing: CGFloat) -> some View {
        self.padding(.leading, spacing)
    }

    func pr(_ spacing: CGFloat) -> some View {
        self.padding(.trailing, spacing)
    }
       
    func ph(_ spacing: CGFloat) -> some View {
        self.padding(.horizontal, spacing)
    }
    
    func pv(_ spacing: CGFloat) -> some View {
        self.padding(.vertical, spacing)
    }

    func pa(_ spacing: CGFloat) -> some View {
        self.padding(.all, spacing)
    }
    
    var phmd: some View {
        self.ph(16.rpx)
    }
    
    var pvsm: some View {
        self.pv(12.rpx)
    }
    var pvmd: some View {
        self.pv(16.rpx)
    }
    
    var pvLarge: some View {
        self.pv(20.rpx)
    }
 
    
    var roundedMedium: some View {
        self.clipRounded(16.rpx)
    }
    
    func clipRounded(_ cornerRadius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    func roundedBG(_ cornerRadius: CGFloat, color: Color) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
        }
    }
    
    func roundedMediumBG(color: Color) -> some View {
        self.roundedBG(16.rpx, color: color)
    }
    
    func backgroundColor(color: Color) -> some View {
        self.background(color)
    }
    
    var backgroundMain: some View {
        self.backgroundColor(color: .mainBG)
    }
    
    var backgroundSecondary: some View {
        self.backgroundColor(color: .mainColor2)
    }
    
    func capsuleBG(_ color: Color) -> some View {
        self.background {
            Capsule().fill(color)
        }
    }

    func capsuleBorder(_ color: Color, lineWidth: CGFloat = 1) -> some View {
        self.background {
            Capsule().stroke(color, lineWidth: lineWidth)
        }
    }
    
    var capsuleG0LBG: some View {
        self.capsuleBG(.g0L)
    }
    
    // border
    func roundedBorder(_ cornerRadius: CGFloat, color: Color, lineWidth: CGFloat = 1) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: lineWidth / 2.0)
                .stroke(color, lineWidth: lineWidth)
        }
    }
    
    func height(_ height: CGFloat) -> some View {
        self.frame(height: height)
    }

    func width(_ width: CGFloat) -> some View {
        self.frame(width: width)
    }

    func size(width: CGFloat, height: CGFloat) -> some View {
        self.frame(width: width, height: height)
    }
}

// TODO: 不知道放哪
struct HUD {
    @MainActor
    static func showLoading() {
        GLToast.showLoading()
    }
    
    @MainActor
    static func dismiss() {
        GLToast.dismiss()
    }
    
    @MainActor
    static func showError(_ msg: String) {
        GLToast.showError(msg)
    }
    
    @MainActor
    static func showMsg(_ msg: String) {
        GLToast.show(msg)
    }
}
