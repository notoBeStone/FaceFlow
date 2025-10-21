//
//  AttributeImagePlaceholder.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI

/// 属性图片占位符视图
/// 用于显示面部属性的示意图，暂时使用 SF Symbols 和渐变背景
struct AttributeImagePlaceholder: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
            
            // 图标
            iconView
            
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconView: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .foregroundColor(.white.opacity(0.9))
    }
    
    
    // MARK: - Computed Properties
    
    /// 根据图片名称返回对应的 SF Symbol
    private var sfSymbol: String {
        // 脸型
        if imageName.contains("face_") {
            return "face.smiling"
        }
        // 颧骨
        else if imageName.contains("cheekbone") {
            return "sparkles"
        }
        // 下颌线
        else if imageName.contains("jawline") {
            return "line.3.horizontal.decrease"
        }
        // 下巴
        else if imageName.contains("chin") {
            return "triangle"
        }
        // 眼睛大小
        else if imageName.contains("eye_size") {
            return "eye"
        }
        // 眼睛形状
        else if imageName.contains("eye_shape") {
            return "eye.fill"
        }
        // 眼距
        else if imageName.contains("eye_distance") {
            return "arrow.left.and.right"
        }
        // 眉毛
        else if imageName.contains("eyebrow") {
            return "minus"
        }
        // 鼻子长度
        else if imageName.contains("nose_length") {
            return "arrow.up.and.down"
        }
        // 鼻子宽度
        else if imageName.contains("nose_width") {
            return "arrow.left.and.right"
        }
        // 嘴唇厚度
        else if imageName.contains("lips_thickness") {
            return "mouth"
        }
        // 嘴唇形状
        else if imageName.contains("lips_shape") {
            return "mouth.fill"
        }
        // 肤质
        else if imageName.contains("skin_type") {
            return "sparkle"
        }
        // 肤色
        else if imageName.contains("skin_tone") {
            return "paintpalette"
        }
        // 年龄
        else if imageName.contains("age_") {
            return "person.fill"
        }
        else {
            return "photo"
        }
    }
    
    /// 根据图片名称返回对应的渐变颜色
    private var gradientColors: [Color] {
        // 脸型 - 粉色系
        if imageName.contains("face_") {
            return [Color(hex: "FFB6C1"), Color(hex: "FFA0B4")]
        }
        // 颧骨 - 紫色系
        else if imageName.contains("cheekbone") {
            return [Color(hex: "DDA0DD"), Color(hex: "D891E8")]
        }
        // 下颌线 - 蓝色系
        else if imageName.contains("jawline") {
            return [Color(hex: "87CEEB"), Color(hex: "6BB6E3")]
        }
        // 下巴 - 青色系
        else if imageName.contains("chin") {
            return [Color(hex: "40E0D0"), Color(hex: "20C9B8")]
        }
        // 眼睛 - 绿色系
        else if imageName.contains("eye_") {
            return [Color(hex: "98D8C8"), Color(hex: "7CC9B7")]
        }
        // 眉毛 - 棕色系
        else if imageName.contains("eyebrow") {
            return [Color(hex: "CD853F"), Color(hex: "B87333")]
        }
        // 鼻子 - 橙色系
        else if imageName.contains("nose_") {
            return [Color(hex: "FFB347"), Color(hex: "FFA533")]
        }
        // 嘴唇 - 玫瑰色系
        else if imageName.contains("lips_") {
            return [Color(hex: "FF69B4"), Color(hex: "FF5AA4")]
        }
        // 肤质 - 米色系
        else if imageName.contains("skin_type") {
            return [Color(hex: "F5DEB3"), Color(hex: "E8CFA3")]
        }
        // 肤色 - 桃色系
        else if imageName.contains("skin_tone") {
            return [Color(hex: "FFDAB9"), Color(hex: "FFCBA9")]
        }
        // 年龄 - 紫红色系
        else if imageName.contains("age_") {
            return [Color(hex: "BA55D3"), Color(hex: "A845C3")]
        }
        else {
            return [Color(hex: "CCCCCC"), Color(hex: "AAAAAA")]
        }
    }
    
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            AttributeImagePlaceholder(imageName: "face_round")
                .frame(width: 100, height: 100)
            
            AttributeImagePlaceholder(imageName: "eye_shape_double")
                .frame(width: 100, height: 100)
            
            AttributeImagePlaceholder(imageName: "skin_tone_natural")
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 16) {
            AttributeImagePlaceholder(imageName: "nose_length_normal")
                .frame(width: 100, height: 100)
            
            AttributeImagePlaceholder(imageName: "lips_shape_balanced")
                .frame(width: 100, height: 100)
            
            AttributeImagePlaceholder(imageName: "age_26_35")
                .frame(width: 100, height: 100)
        }
    }
    .padding()
}
#endif

