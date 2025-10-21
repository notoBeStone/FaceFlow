//
//  FaceAttributesOnboardingContainer.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import SwiftData

/// 面部属性 Onboarding 主容器
struct FaceAttributesOnboardingContainer: View {
    @StateObject private var flow = FaceAttributesOnboardingFlow()
    @Environment(\.modelContext) private var modelContext
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if flow.isShowingEncouragement {
                // 显示鼓励页面
                EncouragementPage(
                    stage: flow.stages[flow.currentStageIndex + 1],
                    onContinue: {
                        flow.moveToNextStage()
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            } else if let question = flow.currentQuestion {
                // 显示问题页面 - 统一使用 AttributeSelectionPage（会自动根据问题类型选择样式）
                AttributeSelectionPage(
                    question: question,
                    onSelect: { value in
                        flow.selectAnswer(questionId: question.id, value: value)
                        
                        // 检查是否完成
                        if flow.isLastStage && flow.isLastQuestionInStage {
                            saveAttributesAndComplete()
                        }
                    },
                    onSkip: {
                        flow.skipQuestion()
                        
                        // 检查是否完成
                        if flow.isLastStage && flow.isLastQuestionInStage {
                            saveAttributesAndComplete()
                        }
                    },
                    progress: flow.progress
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                // 完成页面（可选）
                CompletionView {
                    onComplete()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: flow.currentQuestionIndex)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: flow.isShowingEncouragement)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: flow.isCompleted)
    }
    
    // MARK: - Save & Complete
    
    private func saveAttributesAndComplete() {
        Task { @MainActor in
            do {
                // 保存用户属性到 SwiftData
                try await saveUserAttributes()
                
                // 延迟显示完成页面
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    flow.completeFlow()
                }
                
                print("✅ 用户面部属性已保存")
            } catch {
                print("❌ 保存用户属性失败: \(error)")
            }
        }
    }
    
    private func saveUserAttributes() async throws {
        // 检查是否已存在用户属性
        let descriptor = FetchDescriptor<UserFaceAttributes>()
        let existingAttributes = try modelContext.fetch(descriptor)
        
        let attributes: UserFaceAttributes
        if let existing = existingAttributes.first {
            attributes = existing
        } else {
            attributes = UserFaceAttributes()
            modelContext.insert(attributes)
        }
        
        // 从回答中提取各个属性
        attributes.faceShape = flow.selectedAnswers["faceShape"]
        attributes.cheekboneProminence = flow.selectedAnswers["cheekboneProminence"]
        attributes.jawlineType = flow.selectedAnswers["jawlineType"]
        attributes.chinShape = flow.selectedAnswers["chinShape"]
        attributes.eyeSize = flow.selectedAnswers["eyeSize"]
        attributes.eyeShape = flow.selectedAnswers["eyeShape"]
        attributes.eyeDistance = flow.selectedAnswers["eyeDistance"]
        attributes.eyebrowShape = flow.selectedAnswers["eyebrowShape"]
        attributes.noseLength = flow.selectedAnswers["noseLength"]
        attributes.noseWidth = flow.selectedAnswers["noseWidth"]
        attributes.lipsThickness = flow.selectedAnswers["lipsThickness"]
        attributes.lipsShape = flow.selectedAnswers["lipsShape"]
        attributes.skinType = flow.selectedAnswers["skinType"]
        attributes.skinTone = flow.selectedAnswers["skinTone"]
        attributes.ageRange = flow.selectedAnswers["ageRange"]
        
        attributes.updatedAt = Date()
        
        try modelContext.save()
        
        print("✅ 保存的属性: \(attributes.getAllTags())")
    }
}

// MARK: - Completion View

struct CompletionView: View {
    let onComplete: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color(hex: "FF6B9D"), Color(hex: "FF8FB3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 完成图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                
                VStack(spacing: 16) {
                    Text(GLMPLanguage.faceAttributes_completion_perfect)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(GLMPLanguage.faceAttributes_completion_message)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                
                Spacer()
                
                // 开始按钮
                Button(action: onComplete) {
                    Text(GLMPLanguage.common_start_exploring)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "FF6B9D"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
            }
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    FaceAttributesOnboardingContainer {
        print("Onboarding completed")
    }
}
#endif

