//
//  GLImageView.swift
//  AINote
//
//  Created by 彭瑞淋 on 2024/10/31.
//

import Foundation
import SwiftUI
import GLUtils

struct GLImageView: View {
    // 支持多种图片来源
    enum Source {
        case system(String)          // SF Symbols
        case asset(String)           // Asset Catalog
        case uiImage(UIImage)       // UIImage 实例
    }
    
    private let source: Source
    private var contentMode: ContentMode = .fill
    private var tint: Color?
    private var width: CGFloat?
    private var height: CGFloat?
    private var cornerRadius: CGFloat = 0
    
    // 初始化方法
    init(source: Source) {
        self.source = source
    }
    
    // 便利初始化方法
    init(named: String) {
        self.source = .asset(named)
    }
    
    init(systemName: String) {
        self.source = .system(systemName)
    }
    
    init(uiImage: UIImage) {
        self.source = .uiImage(uiImage)
    }
    
    var body: some View {
        // 根据不同来源创建 Image
        image
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: width, height: height)
            .if(tint != nil, transform: { view in
                view.foregroundStyle(tint!)
            })
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle()) // 扩大点击区域
    }
    
    // 私有计算属性处理不同图片来源
    private var image: Image {
        switch source {
        case .system(let name):
            return Image(systemName: name)
        case .asset(let name):
            return Image(name)
        case .uiImage(let uiImage):
            return Image(uiImage: uiImage)
        }
    }
}

// 修饰器
extension GLImageView {
    // 设置填充模式
    func contentMode(_ mode: ContentMode) -> GLImageView {
        var view = self
        view.contentMode = mode
        return view
    }
    
    // 设置尺寸
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> GLImageView {
        var view = self
        view.width = width
        view.height = height
        return view
    }
    
    // 设置圆角
    func cornerRadius(_ radius: CGFloat) -> GLImageView {
        var view = self
        view.cornerRadius = radius
        return view
    }
    
    // 设置前景色
    func foregroundStyle(_ color: Color) -> GLImageView {
        var view = self
        view.tint = color
        return view
    }
}
