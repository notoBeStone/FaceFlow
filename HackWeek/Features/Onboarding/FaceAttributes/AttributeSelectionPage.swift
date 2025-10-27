//
//  AttributeSelectionPage.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import GLUtils
import GLMP
import GLTrackingExtension

/// 属性选择页面 - 深色背景 + 卡片样式
struct AttributeSelectionPage: View {
    let question: AttributeQuestion
    let onSelect: (String) -> Void
    let onSkip: () -> Void
    let progress: Double
    
    @State private var selectedOptionId: String?
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .frame(height: GLScreenHeight)
            
            VStack(spacing: 0) {
                // 顶部进度指示器
                topProgressIndicator
                    .padding(.top, GLSafeStatusBarHeight + 16)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 50)
                
                // 问题标题
                questionHeader
                    .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 47)
                
                // 选项列表
                optionsList
                    .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 页面曝光埋点
            GLMPTracking.tracking("onboarding_attribute_exposure", parameters: [
                GLT_PARAM_TYPE: question.id
            ])
        }
    }
    
    // MARK: - Top Progress Indicator
    
    private var topProgressIndicator: some View {
        HStack(spacing: 8) {
            // 第一个指示器 (第一题时变白)
            ZStack {}
                .frame(width: 40, height: 4)
                .background(.white)
                .cornerRadius(2)
            
            // 第二个指示器 (第二题时变白)
            if progress >= 0.5 {
                // 已完成或进行中
                ZStack {}
                    .frame(width: 40, height: 4)
                    .background(.white)
                    .cornerRadius(2)
            } else {
                // 未开始
                ZStack {}
                    .frame(width: 40, height: 4)
                    .background(.white.opacity(0.18))
                    .cornerRadius(2)
            }
        }
    }
    
    // MARK: - Question Header
    
    private var questionHeader: some View {
        VStack(spacing: 8) {
            Text(question.question)
                .font(Font.custom("Avenir", size: 24).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                .frame(width: 343, alignment: .top)
            
            if let subtitle = question.subtitle {
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Options List
    
    private var optionsList: some View {
        VStack(spacing: 16) {
            ForEach(question.options) { option in
                OptionCardButton(
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
        
        // 选项点击埋点
        GLMPTracking.tracking("onboarding_attribute_option_click", parameters: [
            GLT_PARAM_TYPE: question.id,
            GLT_PARAM_VALUE: option.value
        ])
        
        // 添加触觉反馈
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // 延迟一下让用户看到选中效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onSelect(option.value)
        }
    }
}

// MARK: - Option Card Button

struct OptionCardButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .padding(.vertical, 20)
            .frame(width: 335, alignment: .center)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 1, green: 0.89, blue: 0.95, opacity: 0.16), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.96, green: 0.89, blue: 1, opacity: 0.16), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 0.5),
                    endPoint: UnitPoint(x: 1, y: 0.5)
                )
            )
            .cornerRadius(12)
            .overlay(
                // 选中后的白色边框
                RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.8)
                .stroke(isSelected ? Color(red: 1, green: 0.3, blue: 0.56) : .clear, lineWidth: 1.6)
                    
            )
            .shadow(color: .black.opacity(0.07), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
            id: "ageRange",
            question: "What's your age?",
            subtitle: "Help us recommend age-appropriate content.",
            options: [
                AttributeOption(id: "under18", title: "Under 18", imageName: "", value: "Under18"),
                AttributeOption(id: "19to25", title: "19-25", imageName: "", value: "19-25"),
                AttributeOption(id: "26to35", title: "26-35", imageName: "", value: "26-35"),
                AttributeOption(id: "36to45", title: "36-45", imageName: "", value: "36-45"),
                AttributeOption(id: "over45", title: "Over 45", imageName: "", value: "Over45")
            ],
            attributeType: .ageRange
        ),
        onSelect: { value in
            print("Selected: \(value)")
        },
        onSkip: {
            print("Skipped")
        },
        progress: 0.0
    )
}
#endif
