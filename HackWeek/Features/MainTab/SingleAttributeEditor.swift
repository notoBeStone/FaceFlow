//
//  SingleAttributeEditor.swift
//  HackWords
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import SwiftData

/// 单个面部属性编辑器 - 只编辑一个属性
struct SingleAttributeEditor: View {
    let question: AttributeQuestion
    let currentValue: String?
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var selectedValue: String?
    
    init(question: AttributeQuestion, currentValue: String?, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.question = question
        self.currentValue = currentValue
        self.onSave = onSave
        self.onCancel = onCancel
        _selectedValue = State(initialValue: currentValue)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBG
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 问题内容区域
                    ScrollView {
                        VStack(spacing: 24) {
                            // 问题标题
                            VStack(spacing: 8) {
                                Text(question.question)
                                    .font(.avenirTitle2Heavy)
                                    .foregroundColor(.g9L)
                                    .multilineTextAlignment(.center)
                                
                                if let subtitle = question.subtitle {
                                    Text(subtitle)
                                        .font(.avenirBodyRoman)
                                        .foregroundColor(.g6L)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 24)
                            
                            // 选项列表
                            optionsList
                        }
                        .padding(.bottom, 100) // 为保存按钮留出空间
                    }
                    
                    Spacer()
                }
                
                // 底部保存按钮
                VStack {
                    Spacer()
                    
                    saveButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .background(
                            LinearGradient(
                                colors: [Color.mainBG.opacity(0), Color.mainBG],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                            .allowsHitTesting(false)
                        )
                }
            }
            .navigationTitle(GLMPLanguage.me_edit_profile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(GLMPLanguage.text_cancel) {
                        onCancel()
                    }
                    .foregroundColor(.mainColor)
                }
            }
        }
    }
    
    // MARK: - Options List
    
    @ViewBuilder
    private var optionsList: some View {
        if useListStyle {
            // 列表样式（用于年龄、肤质等）
            VStack(spacing: 12) {
                ForEach(question.options) { option in
                    listOptionCard(option: option)
                }
            }
            .padding(.horizontal, 20)
        } else {
            // 网格样式（用于其他属性）
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(question.options) { option in
                    gridOptionCard(option: option)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // 判断是否使用列表样式
    private var useListStyle: Bool {
        return question.id == "ageRange" || question.id == "skinType" || question.id == "skinTone"
    }
    
    private var gridColumns: [GridItem] {
        let optionCount = question.options.count
        
        // 根据选项数量决定列数
        if optionCount <= 2 {
            // 1-2个选项：固定2列
            return [GridItem(.flexible()), GridItem(.flexible())]
        } else if optionCount <= 4 {
            // 3-4个选项：固定2列，每列平均分配
            return [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        } else {
            // 5个以上选项：自适应布局
            return [GridItem(.adaptive(minimum: 140), spacing: 12)]
        }
    }
    
    // MARK: - Option Cards
    
    private func listOptionCard(option: AttributeOption) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedValue = option.value
            }
        } label: {
            HStack(spacing: 16) {
                // 选项图片
                Image(option.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 选项标题
                Text(option.title)
                    .font(.avenirBodyMedium)
                    .foregroundColor(.g9L)
                
                Spacer()
                
                // 选中指示器
                Image(systemName: selectedValue == option.value ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(selectedValue == option.value ? .mainColor : .g4L)
            }
            .padding(16)
            .background(Color.gwL)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedValue == option.value ? Color.mainColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func gridOptionCard(option: AttributeOption) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedValue = option.value
            }
        } label: {
            VStack(spacing: 12) {
                // 选项图片
                Image(option.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 选项标题
                Text(option.title)
                    .font(.avenirBodyRoman)
                    .foregroundColor(.g9L)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gwL)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedValue == option.value ? Color.mainColor : Color.g4L, lineWidth: selectedValue == option.value ? 2.5 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button {
            if let value = selectedValue {
                onSave(value)
            } else {
                onCancel()
            }
        } label: {
            Text(GLMPLanguage.text_save)
                .font(.avenirBodyHeavy)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: selectedValue != nil ? [.mainColor, .mainSecondary] : [.g4L, .g4L],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: selectedValue != nil ? Color.mainColor.opacity(0.3) : Color.clear,
                    radius: 12,
                    x: 0,
                    y: 4
                )
        }
        .disabled(selectedValue == nil)
        .animation(.easeInOut(duration: 0.2), value: selectedValue)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SingleAttributeEditor(
        question: FaceAttributesQuestionFactory.createEyebrowQuestion(),
        currentValue: EyebrowShape.angular.rawValue,
        onSave: { value in
            print("Saved: \(value)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
#endif
