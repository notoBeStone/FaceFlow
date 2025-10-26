//
//  SingleAttributeEditor.swift
//  HackWords
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import SwiftData
import GLUtils

/// 单个面部属性编辑器 - 只编辑一个属性
struct SingleAttributeEditor: View {
    let question: AttributeQuestion
    let currentValue: String?
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var selectedValue: String?
    @Environment(\.dismiss) private var dismiss
    
    init(question: AttributeQuestion, currentValue: String?, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.question = question
        self.currentValue = currentValue
        self.onSave = onSave
        self.onCancel = onCancel
        _selectedValue = State(initialValue: currentValue)
    }
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                navigationBar
                    .padding(.top, GLSafeStatusBarHeight)
                
                Spacer()
                    .frame(height: 50)
                
                // 问题标题
                questionHeader
                    .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 47)
                
                // 选项列表
                ScrollView {
                    optionsList
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack {
            Button {
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Question Header
    
    private var questionHeader: some View {
        VStack(spacing: 8) {
            Text(question.question)
                .font(Font.custom("Avenir", size: 24).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                .frame(maxWidth: .infinity, alignment: .center)
            
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
                    isSelected: selectedValue == option.value,
                    action: {
                        handleSelection(option)
                    }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSelection(_ option: AttributeOption) {
        selectedValue = option.value
        
        // 添加触觉反馈
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // 延迟一下让用户看到选中效果，然后自动保存并关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onSave(option.value)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SingleAttributeEditor(
        question: FaceAttributesQuestionFactory.createEyebrowQuestion(),
        currentValue: EyebrowShape.angular.rawValue,
        onSave: { value in
            debugPrint("Saved: \(value)")
        },
        onCancel: {
            debugPrint("Cancelled")
        }
    )
}
#endif
