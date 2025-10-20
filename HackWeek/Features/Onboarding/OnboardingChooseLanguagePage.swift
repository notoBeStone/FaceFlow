//
//  OnboardingChooseLanguagePage.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI

/// Onboarding语言选择页面ViewModel
class OnboardingLanguageViewModel: ComposableViewModel {

    /// 处理语言选择
    func handleLanguageSelection(_ language: OnboardingLanguage) {
        tracking("onboarding_language_select_click", [
            .TRACK_KEY_FROM: "onboarding_language",
            .TRACK_KEY_TYPE: language.languageCode,
            .TRACK_KEY_CONTENT: "language_selection"
        ])

        // 保存用户选择的语言并标记Onboarding完成
        Task { @MainActor in
            OnboardingManager.shared.updateTargetLanguage(language)
            OnboardingManager.shared.markOnboardingCompleted()
        }

        // 进入主应用或完成流程
        completeOnboarding()
    }

    /// 完成Onboarding流程
    private func completeOnboarding() {
        // TODO: 实现Onboarding完成后的动作
        // 这里可以导航到主应用或显示完成页面
    }
}

/// Onboarding语言选择页面Props
struct OnboardingLanguagePageProps {
    var onLanguageSelected: ((OnboardingLanguage) -> Void)?
}

/// Onboarding语言选择页面
struct OnboardingChooseLanguagePage: ComposablePageComponent {

    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = OnboardingLanguagePageProps

    let props: ComponentProps

    init(props: ComponentProps = OnboardingLanguagePageProps()) {
        self.props = props
        viewModel = OnboardingLanguageViewModel()
    }

    var pageName: String { "onboarding_language" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "onboarding",
            .TRACK_KEY_TYPE: "language_selection"
        ]
    }

    // MARK: - State Variables
    @ObservedObject private var viewModel: OnboardingLanguageViewModel

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 顶部标题
                VStack(spacing: 16) {
                    Text("Choose your language to learn")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("Select the language you want to focus on")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 80)
                .padding(.horizontal, 24)

                Spacer()

                // 语言选项
                VStack(spacing: 16) {
                    ForEach(OnboardingLanguage.allCases, id: \.self) { language in
                        LanguageOptionButton(
                            language: language,
                            onTap: {
                                viewModel.handleLanguageSelection(language)
                                props.onLanguageSelected?(language)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .connect(viewModel: viewModel)
    }
}

/// 语言选项按钮
struct LanguageOptionButton: View {
    let language: OnboardingLanguage
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayText)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)

                    Text(getLanguageDescription(language))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    /// 获取语言描述
    private func getLanguageDescription(_ language: OnboardingLanguage) -> String {
        switch language {
        case .spanish:
            return "Español - Learn Spanish vocabulary"
        case .chinese:
            return "中文 - Learn Chinese vocabulary"
        case .japanese:
            return "日本語 - Learn Japanese vocabulary"
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    OnboardingChooseLanguagePage(props: OnboardingLanguagePageProps { language in
        print("Selected language: \(language.rawValue)")
    })
}
#endif