//
//  ViewModifier.swift
//  AINote
//
//  Created by user on 2024/5/22.
//

import SwiftUI
import SwiftUIIntrospect
import GLUtils

extension View {
    func gl_endEditing() {
        UIApplication.shared.endEditing()
    }
    
    func ifRTL() -> AnyView {
        if GLDevice.isRTL() {
            return AnyView(self.rotationEffect(.degrees(180)))
        }
        return AnyView(self)
    }
    
    var anyView: AnyView {
        return AnyView(self)
    }
    
    func rotateForever(duration: Double = 2.0) -> AnyView {
        GLRotateForeverView(view: self, rotate: .constant(true), duration: duration).anyView
    }
    
    func gl_disable(_ disable: Bool, opacity: Double = 0.6)  -> some View {
        return self.disabled(disable).opacity(disable ? opacity : 1.0)
    }
    
    func textEditorBackground(_ color: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden).background(color)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return self.background(color)
        }
    }
    
    func textEditorInnerInset()  -> some View {
        return ZStack {
            self
        }
        .padding(Consts.textEditorInset)
        .clipped()
    }
    
    func textSelectionEnable(_ enable: Bool = true) -> some View {
        if #available(iOS 16.0, *) {
            return ModifiedContent(content: self, modifier: TextSelectionEnable(enable: enable))
        } else {
            return self
        }
    }
}

extension View {
    func introspectScrollView(_ callback: @escaping (_ scrollView: UIScrollView)->()) -> some View {
        return self.introspect(.scrollView, on: .iOS(.v15, .v16, .v17,.v18)) {
            callback($0)
        }
    }
    
    func introspectTextField(_ callback: @escaping (_ textField: UITextField)->()) -> some View {
        return self.introspect(.textField, on: .iOS(.v15, .v16, .v17,.v18)) {
            callback($0)
        }
    }
    
    func introspectTextView(_ callback: @escaping (_ textView: UITextView)->()) -> some View {
        return self.introspect(.textEditor, on: .iOS(.v15, .v16, .v17,.v18)) {
            callback($0)
        }
    }
}

func ZerorSpacer() -> some View {
    Spacer(minLength: 0)
}

fileprivate struct TextSelectionEnable: ViewModifier {
    let enable: Bool
    public func body(content: Content) -> some View {
        if enable {
            content.textSelection(.enabled)
        } else {
            content.textSelection(.disabled)
        }
    }
}
