//
//  TrialCancelSurveyPage.swift
//  HackWeek
//
//  Created by AI Assistant on 2025/10/16.
//

import SwiftUI
import GLTrackingExtension

/// 取消订阅问卷页面 Props
struct TrialCancelSurveyPageProps {
    /// 问卷类型
    let surveyType: SurveyCancelType
    /// 关闭回调
    let onDismiss: (() -> Void)?
    
    init(surveyType: SurveyCancelType = .currentType, onDismiss: (() -> Void)? = nil) {
        self.surveyType = surveyType
        self.onDismiss = onDismiss
    }
}

/// 取消订阅问卷页面
/// 符合 ComposablePageComponent 协议的包装组件
struct TrialCancelSurveyPage: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = TrialCancelSurveyPageProps
    
    let props: ComponentProps
    
    init(props: ComponentProps = TrialCancelSurveyPageProps()) {
        self.props = props
    }
    
    var pageName: String { "trial_cancel_survey" }
    
    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_TYPE: props.surveyType.rawValue,
            .TRACK_KEY_FROM: "main_app"
        ]
    }
    
    // MARK: - Body
    var body: some View {
        TrialCancelSurveyView(
            onDismissAction: handleDismiss,
            onSubmitAction: handleSubmit
        )
        .onAppear {
            // 页面展示时记录
            SurveyFatigueManager.shared.markSurveyShown(type: props.surveyType)
        }
    }
    
    // MARK: - Actions
    
    /// 处理关闭操作
    private func handleDismiss() {
        // 记录用户关闭行为
        SurveyFatigueManager.shared.markSurveyDismissed()
        
        // 执行关闭回调
        props.onDismiss?()
        
        // 关闭页面
        Navigator.dismiss()
    }
    
    /// 处理提交操作
    private func handleSubmit() {
        // 记录用户提交
        SurveyFatigueManager.shared.markSurveySubmitted()
        
        // 执行关闭回调
        props.onDismiss?()
        
        // 关闭页面
        Navigator.dismiss()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    TrialCancelSurveyPage()
}
#endif

