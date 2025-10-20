//
//  GLTextViewWrapper.swift
//  AINote
//
//  Created by user on 2024/10/10.
//

import Foundation
import UIKit
import SwiftUI
import GLUtils
import GLResource


struct GLTextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    //config
    private var backgroundColor: Color = .g1N
    private var font: UIFont = .footnoteMedium
    private var textColor: Color = .g9
    private var contentInset: EdgeInsets = .init(top: 4.rpx, leading: 12.rpx, bottom: 4.rpx, trailing: 12.rpx)
    
    private var placeholderFont: UIFont = .footnoteRegular
    private var placeholderColor: Color = .g5
    
    init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }


    // 2. 创建和配置 UITextView
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }


    // 3. 更新 UITextView 的内容
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.backgroundColor = UIColor(backgroundColor)
        uiView.gl_placeholder.text = placeholder
        uiView.gl_placeholderFont = .footnoteRegular
        uiView.gl_placeholderColor = UIColor(placeholderColor)
        uiView.textColor = UIColor(textColor)
        
        let inset = UIEdgeInsets(top: contentInset.top, left: contentInset.leading, bottom: contentInset.bottom, right: contentInset.trailing)
        uiView.gl_placeholder.contentInset = inset
        uiView.contentInset = inset
    }


    // 4. 使用 Coordinator 来处理 UITextViewDelegate
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }


    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GLTextViewWrapper


        init(_ parent: GLTextViewWrapper) {
            self.parent = parent
        }


        func textViewDidChange(_ textView: UITextView) {
            // 更新绑定的文本
            parent.text = textView.text
        }
    }
}

extension GLTextViewWrapper {
    
    func textFont(_ font: UIFont) -> GLTextViewWrapper {
        var copy = self
        copy.font = font
        return copy
    }
    
    func textColor(_ color: Color) -> GLTextViewWrapper {
        var copy = self
        copy.textColor = color
        return copy
    }
    
    func backgroundColor(_ color: Color) -> GLTextViewWrapper {
        var copy = self
        copy.backgroundColor = color
        return copy
    }
    
    func contentInset(_ inset: EdgeInsets) -> GLTextViewWrapper {
        var copy = self
        copy.contentInset = inset
        return copy
    }
    
    func placeholderFont(_ font: UIFont) -> GLTextViewWrapper {
        var copy = self
        copy.placeholderFont = font
        return copy
    }
    
    func placeholderColor(_ color: Color) -> GLTextViewWrapper {
        var copy = self
        copy.placeholderColor = color
        return copy
    }
}
