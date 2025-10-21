//
//  AttributeSelectionPage.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import GLUtils

/// 通用的属性选择页面 - 支持图片网格和列表两种样式
struct AttributeSelectionPage: View {
    let question: AttributeQuestion
    let onSelect: (String) -> Void
    let onSkip: () -> Void
    let progress: Double
    
    @State private var selectedOptionId: String?
    
    // 判断是否使用列表样式（年龄、肤质、肤色）
    private var useListStyle: Bool {
        return question.id == "ageRange" || question.id == "skinType" || question.id == "skinTone"
    }
    
    // 自适应网格布局 - 根据屏幕宽度自动调整列数
    private var gridColumns: [GridItem] {
        let optionCount = question.options.count
        
        if optionCount <= 2 {
            // 1-2个选项：2列固定布局
            return [GridItem(.flexible()), GridItem(.flexible())]
        } else {
            // 3-4个选项：自适应布局，最小宽度100，最多2列
            return [GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 12)]
        }
    }
    
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(hex: "FFF5F7"), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部进度条和跳过按钮
                topBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 问题标题区域
                        questionHeader
                        
                        // 根据类型显示不同样式的选项
                        if useListStyle {
                            optionsList
                        } else {
                            optionsGrid
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, GLSafeStatusBarHeight)
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                // 进度条
                ProgressView(value: progress)
                    .tint(Color(hex: "FF6B9D"))
                
                // 跳过按钮
                Button(action: onSkip) {
                    Text(GLMPLanguage.common_skip)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "999999"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Question Header
    
    private var questionHeader: some View {
        VStack(spacing: 12) {
            Text(question.question)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "1A1A1A"))
                .multilineTextAlignment(.center)
            
            if let subtitle = question.subtitle {
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "666666"))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Options Grid (for image-based options)
    
    private var optionsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(question.options) { option in
                OptionCard(
                    option: option,
                    isSelected: selectedOptionId == option.id
                ) {
                    handleSelection(option)
                }
            }
        }
    }
    
    // MARK: - Options List (for text-based options)
    
    private var optionsList: some View {
        VStack(spacing: 12) {
            ForEach(question.options) { option in
                ListOptionButton(
                    title: option.title,
                    isSelected: selectedOptionId == option.id,
                    action: {
                        handleSelection(option)
                    }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSelection(_ option: AttributeOption) {
        selectedOptionId = option.id
        
        // 添加触觉反馈
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // 延迟一下让用户看到选中效果
        let delay = useListStyle ? 0.15 : 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            onSelect(option.value)
        }
    }
}

// MARK: - Option Card

struct OptionCard: View {
    let option: AttributeOption
    let isSelected: Bool
    let onTap: () -> Void
    
    // 根据布局模式调整尺寸
    private var imageHeight: CGFloat {
        100
    }
    
    private var cardPadding: CGFloat {
        10
    }
    
    private var fontSize: CGFloat {
        14
    }
    
    private var cornerRadius: CGFloat {
        14
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 图片占位符 - 固定容器内 fit 显示
                ZStack {
                    Color(hex: "F5F5F5")
                    
                    AttributeImagePlaceholder(imageName: option.imageName)
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                }
                .frame(width: imageHeight, height: imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // 标题
                Text(option.title)
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 36)
            }
            .frame(maxWidth: .infinity)
            .padding(cardPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isSelected ? Color(hex: "FF6B9D").opacity(0.1) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected ? Color(hex: "FF6B9D") : Color(hex: "E5E5E5"),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "FF6B9D").opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - List Option Button

struct ListOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(hex: "1A1A1A"))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? 
                          LinearGradient(
                            colors: [Color(hex: "FF6B9D"), Color(hex: "C86DD7")],
                            startPoint: .leading,
                            endPoint: .trailing
                          ) : 
                          LinearGradient(
                            colors: [Color.white, Color.white],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(hex: "E5E5E5"), lineWidth: 1.5)
            )
            .shadow(
                color: isSelected ? Color(hex: "FF6B9D").opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    AttributeSelectionPage(
        question: AttributeQuestion(
            id: "faceShape",
            question: "你的脸型是？",
            subtitle: "选择最接近你的脸型",
            options: [
                AttributeOption(id: "round", title: "圆形脸", imageName: "face_round", value: "Round"),
                AttributeOption(id: "oval", title: "椭圆形脸", imageName: "face_oval", value: "Oval"),
                AttributeOption(id: "square", title: "方形脸", imageName: "face_square", value: "Square"),
                AttributeOption(id: "oblong", title: "长形脸", imageName: "face_oblong", value: "Oblong"),
                AttributeOption(id: "oblong1", title: "长形脸", imageName: "face_oblong", value: "Oblong"),
                AttributeOption(id: "oblong2", title: "长形脸", imageName: "face_oblong", value: "Oblong")
            ],
            attributeType: .faceShape
        ),
        onSelect: { value in
            print("Selected: \(value)")
        },
        onSkip: {
            print("Skipped")
        },
        progress: 0.25
    )
}
#endif

