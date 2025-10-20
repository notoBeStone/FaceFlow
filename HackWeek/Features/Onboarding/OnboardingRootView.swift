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

    // SwiftData 数据容器
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if onboardingManager.isOnboardingCompleted {
                // Onboarding已完成，显示主应用界面
                MainAppView()
            } else {
                // Onboarding未完成，显示欢迎页面
                OnboardingWelcomePage(props: OnboardingWelcomePageProps {
                    // 欢迎页继续按钮点击后的处理
                    onboardingManager.showAgeSelectionPage()
                })
            }
        }
        .onAppear {
            // 加载Onboarding数据
            onboardingManager.loadOnboardingData()

            // 如果需要显示Onboarding，则显示
            if onboardingManager.shouldShowOnboarding() {
                print("🚀 需要显示Onboarding流程")
            } else {
                print("✅ Onboarding已完成，显示主应用")
            }
        }
    }
}

// MARK: - OnboardingManager Extension
extension OnboardingManager {
    /// 显示年龄选择页面
    func showAgeSelectionPage() {
        let agePage = OnboardingAgePage(props: OnboardingAgePageProps { ageGroup in
            // 年龄选择后的处理 - 导航到语言选择页面
            self.showLanguageSelectionPage()
        })

        // 使用Navigator进行导航
        Navigator.push(agePage, from: "onboarding_welcome")
    }

    /// 显示语言选择页面
    func showLanguageSelectionPage() {
        let languagePage = OnboardingChooseLanguagePage(props: OnboardingLanguagePageProps { language in
            // 语言选择后的处理 - Onboarding流程完成
            self.handleOnboardingCompletion()
        })

        // 使用Navigator进行导航
        Navigator.push(languagePage, from: "onboarding_age")
    }

    /// 处理Onboarding完成
    private func handleOnboardingCompletion() {
        Task { @MainActor in
            markOnboardingCompleted()

            // 检查用户是否为VIP
            let isVip = GL().Account_GetVipInfo()?.isVipInHistory.boolValue ?? false

            // 先重置到主应用界面
            print("🎉 Onboarding完成，重置到主应用界面")
            Navigator.reset(MainAppView())

            // 如果用户非VIP，延迟一小段时间后显示转化页
            if !isVip {
                // 延迟显示转化页，确保主界面已完全加载
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("💰 显示付费转化页")
                    TemplateAPI.Conversion.showVip(from: "onboarding_completion", animationType: .present)
                }
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
