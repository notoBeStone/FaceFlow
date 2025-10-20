//
//  OnboardingWelcomePage.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI

/// Onboarding欢迎页面ViewModel
class OnboardingWelcomeViewModel: ComposableViewModel {

    /// 处理继续按钮点击
    func handleContinueTap() {
        tracking("onboarding_welcome_continue_click", [
            .TRACK_KEY_FROM: "onboarding_welcome",
            .TRACK_KEY_TYPE: "navigation"
        ])

        // 导航到年龄选择页面
        // TODO: 实现页面导航逻辑
    }
}

/// Onboarding欢迎页面Props
struct OnboardingWelcomePageProps {
    var onContinue: (() -> Void)?
}

/// Onboarding欢迎页面
struct OnboardingWelcomePage: ComposablePageComponent {

    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = OnboardingWelcomePageProps

    let props: ComponentProps

    init(props: ComponentProps = OnboardingWelcomePageProps()) {
        self.props = props
        viewModel = OnboardingWelcomeViewModel()
    }

    var pageName: String { "onboarding_welcome" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "onboarding",
            .TRACK_KEY_TYPE: "welcome"
        ]
    }

    // MARK: - State Variables
    @ObservedObject private var viewModel: OnboardingWelcomeViewModel

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                // 应用标题
                Text("HackWords")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.primary)

                Spacer()

                // 继续按钮
                Button(action: {
                    viewModel.handleContinueTap()
                    props.onContinue?()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .connect(viewModel: viewModel)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    OnboardingWelcomePage(props: OnboardingWelcomePageProps {
        print("Continue tapped")
    })
}
#endif