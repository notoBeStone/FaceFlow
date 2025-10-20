//
//  OnboardingAgePage.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI

/// Onboarding年龄选择页面ViewModel
class OnboardingAgeViewModel: ComposableViewModel {

    /// 处理年龄选择
    func handleAgeSelection(_ ageGroup: OnboardingAgeGroup) {
        tracking("onboarding_age_select_click", [
            .TRACK_KEY_FROM: "onboarding_age",
            .TRACK_KEY_TYPE: ageGroup.rawValue,
            .TRACK_KEY_CONTENT: "age_group_selection"
        ])

        // 保存用户选择的年龄组
        Task { @MainActor in
            OnboardingManager.shared.updateAgeGroup(ageGroup)
        }

        // 导航到语言选择页面
        showLanguageSelectionPage()
    }

    /// 显示语言选择页面
    private func showLanguageSelectionPage() {
        // TODO: 实现语言选择页面导航
        // 这里将在创建LanguagePage后实现
    }
}

/// Onboarding年龄选择页面Props
struct OnboardingAgePageProps {
    var onAgeSelected: ((OnboardingAgeGroup) -> Void)?
}

/// Onboarding年龄选择页面
struct OnboardingAgePage: ComposablePageComponent {

    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = OnboardingAgePageProps

    let props: ComponentProps

    init(props: ComponentProps = OnboardingAgePageProps()) {
        self.props = props
        viewModel = OnboardingAgeViewModel()
    }

    var pageName: String { "onboarding_age" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "onboarding",
            .TRACK_KEY_TYPE: "age_selection"
        ]
    }

    // MARK: - State Variables
    @ObservedObject private var viewModel: OnboardingAgeViewModel

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 顶部标题
                VStack(spacing: 16) {
                    Text("How old are you?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("This helps us personalize your learning experience")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 80)
                .padding(.horizontal, 24)

                Spacer()

                // 年龄选项
                VStack(spacing: 16) {
                    ForEach(OnboardingAgeGroup.allCases, id: \.self) { ageGroup in
                        AgeOptionButton(
                            ageGroup: ageGroup,
                            onTap: {
                                viewModel.handleAgeSelection(ageGroup)
                                props.onAgeSelected?(ageGroup)
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

/// 年龄选项按钮
struct AgeOptionButton: View {
    let ageGroup: OnboardingAgeGroup
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(ageGroup.displayText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)

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
}

// MARK: - Preview
#if DEBUG
#Preview {
    OnboardingAgePage(props: OnboardingAgePageProps { ageGroup in
        print("Selected age group: \(ageGroup.rawValue)")
    })
}
#endif