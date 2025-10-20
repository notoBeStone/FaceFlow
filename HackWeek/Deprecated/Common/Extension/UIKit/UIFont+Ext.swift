//
//  UIFont+Ext.swift
//  AINote
//
//  Created by user on 2024/10/10.
//

import UIKit

extension UIFont {
    var italic: UIFont? {
        // 创建一个 UIFontDescriptor，并将斜体属性设置为 true
        let descriptor = self.fontDescriptor.withSymbolicTraits(.traitItalic)
        
        // 使用新的字体描述符创建新的 UIFont 对象
        if let italicFontDescriptor = descriptor {
            return UIFont(descriptor: italicFontDescriptor, size: self.pointSize)
        }
        
        // 返回 nil 如果无法创建斜体字体
        return nil
    }
}
