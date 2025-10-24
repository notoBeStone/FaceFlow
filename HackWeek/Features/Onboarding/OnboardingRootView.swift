//
//  OnboardingRootView.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI
import SwiftData
import GLAccountExtension
import GLCore

/// Onboarding根视图，负责检查Onboarding状态并显示适当的页面
struct OnboardingRootView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @State private var isCarouselCompleted = false

    // SwiftData 数据容器
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if onboardingManager.isOnboardingCompleted {
                // Onboarding已完成，显示主应用界面
                MainAppView()
            } else if !isCarouselCompleted {
                // 显示轮播图
                OnboardingCarouselView {
                    isCarouselCompleted = true
                }
            } else {
                // 轮播完成后，显示面部属性问卷
                FaceAttributesOnboardingContainer {
                    // 问卷完成后的处理
                    onboardingManager.handleOnboardingCompletion()
                }
            }
        }
    }
}

// MARK: - OnboardingManager Extension
extension OnboardingManager {
    /// 处理Onboarding完成
    func handleOnboardingCompletion() {
        Task { @MainActor in
            markOnboardingCompleted()

            // 检查用户是否为VIP
            let isVip = GL().Account_GetVipInfo()?.isVipInHistory.boolValue ?? false

            print("🎉 面部属性问卷完成")

            // 如果用户非VIP，显示转化页
            if !isVip {
                print("💰 显示付费转化页")
                TemplateAPI.Conversion.showVip(from: "onboarding_completion", animationType: .present)
            } else {
                print("✅ 用户是VIP，直接进入主应用")
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    OnboardingRootView()
}
#endif
