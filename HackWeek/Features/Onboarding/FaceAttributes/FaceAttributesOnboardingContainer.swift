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
    
    @State private var showLoadingView = false
    @State private var showReportView = false
    
    let faceImage: UIImage?
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if showReportView {
                // 显示报告页面
                BeautyReportView(faceImage: faceImage) {
                    onComplete()
                }
                .transition(.opacity)
            } else if showLoadingView {
                // 显示加载页面
                FaceAnalysisLoadingView(
                    faceImage: faceImage,
                    onComplete: {
                        // Loading 完成后进入报告页
                        withAnimation {
                            showLoadingView = false
                            showReportView = true
                        }
                    },
                    onError: { _ in
                        // 即使出错也进入报告页（已在 LoadingView 中处理）
                    }
                )
                .transition(.opacity)
            } else if let question = flow.currentQuestion {
                // 显示问题页面
                AttributeSelectionPage(
                    question: question,
                    onSelect: { value in
                        // 先保存答案
                        flow.selectedAnswers[question.id] = value
                        
                        // 判断是否是最后一题
                        if flow.isLastQuestion {
                            // 最后一题：延迟一下让用户看到选中效果，然后进入加载页面
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flow.completeFlow()
                                saveAttributesAndShowLoading()
                            }
                        } else {
                            // 不是最后一题：移动到下一题
                            flow.currentQuestionIndex += 1
                        }
                    },
                    onSkip: {
                        // 判断是否是最后一题
                        if flow.isLastQuestion {
                            // 最后一题：直接进入加载页面
                            flow.completeFlow()
                            saveAttributesAndShowLoading()
                        } else {
                            // 不是最后一题：移动到下一题
                            flow.currentQuestionIndex += 1
                        }
                    },
                    progress: flow.progress
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: flow.currentQuestionIndex)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showLoadingView)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showReportView)
    }
    
    // MARK: - Save & Show Loading
    
    private func saveAttributesAndShowLoading() {
        Task { @MainActor in
            do {
                // 保存用户属性到 SwiftData（只保存 ageRange 和 skinType）
                try await saveUserAttributes()
                
                debugPrint("✅ 用户基础属性已保存（年龄和肤质）")
                
                // 标记流程完成
                flow.completeFlow()
                
                // 显示加载页面（会在加载页面调用 API 分析其他属性）
                withAnimation {
                    showLoadingView = true
                }
            } catch {
                debugPrint("❌ 保存用户属性失败: \(error)")
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
        
        // 只保存用户手动选择的属性（年龄和肤质）
        attributes.ageRange = flow.selectedAnswers["ageRange"]
        attributes.skinType = flow.selectedAnswers["skinType"]
        
        // 其他属性将在 API 分析后填充
        // TODO: 在 FaceAnalysisLoadingView 中调用 API 后，更新以下属性：
        // attributes.faceShape
        // attributes.cheekboneProminence
        // attributes.jawlineType
        // attributes.chinShape
        // attributes.eyeSize
        // attributes.eyeShape
        // attributes.eyeDistance
        // attributes.eyebrowShape
        // attributes.noseLength
        // attributes.noseWidth
        // attributes.lipsThickness
        // attributes.lipsShape
        // attributes.skinTone
        // attributes.skinBlemishes
        
        attributes.updatedAt = Date()
        
        try modelContext.save()
        
        debugPrint("✅ 保存的基础属性: 年龄=\(attributes.ageRange ?? "nil"), 肤质=\(attributes.skinType ?? "nil")")
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
    FaceAttributesOnboardingContainer(faceImage: nil) {
        debugPrint("Onboarding completed")
    }
}
#endif

