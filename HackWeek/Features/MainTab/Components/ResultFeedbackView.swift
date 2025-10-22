//
//  ResultFeedbackView.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import GLMP
import GLCore
import GLTrackingExtension

/// 分析结果反馈组件
struct ResultFeedbackView: View {
    let recordId: String
    let score: String
    let analysisType: AnalysisType
    var customTitle: String? = nil
    var isDarkMode: Bool = false
    
    @State private var selectedFeedback: FeedbackType?
    @State private var showDetailInput = false
    @State private var feedbackDetail: String = ""
    @State private var showThanks = false
    
    enum AnalysisType: String {
        case makeup = "makeup_result"
        case product = "product_result"
        case video = "video_player"
    }
    
    enum FeedbackType: String {
        case helpful = "helpful"
        case notHelpful = "not_helpful"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            Text(customTitle ?? GLMPLanguage.feedback_analysis_helpful)
                .font(.avenirBodyMedium)
                .foregroundColor(isDarkMode ? .white.opacity(0.8) : .g7L)
            
            // 反馈内容区域（保持固定高度）
            Group {
                if !showThanks {
                    VStack(spacing: 16) {
                        // 反馈按钮
                        HStack(spacing: 12) {
                            // Yes 按钮
                            FeedbackButton(
                                icon: "hand.thumbsup.fill",
                                text: GLMPLanguage.feedback_yes,
                                isSelected: selectedFeedback == .helpful,
                                isDarkMode: isDarkMode
                            ) {
                                handleFeedback(.helpful)
                            }
                            
                            // No 按钮
                            FeedbackButton(
                                icon: "hand.thumbsdown.fill",
                                text: GLMPLanguage.feedback_no,
                                isSelected: selectedFeedback == .notHelpful,
                                isDarkMode: isDarkMode
                            ) {
                                handleFeedback(.notHelpful)
                            }
                        }
                        
                        // 详细反馈输入区域
                        if showDetailInput {
                            VStack(spacing: 12) {
                                Text(GLMPLanguage.feedback_detail_title)
                                    .font(.avenirBodyRoman)
                                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .g6L)
                                
                                // 文本输入框
                                TextEditor(text: $feedbackDetail)
                                    .font(.avenirBodyRoman)
                                    .foregroundColor(isDarkMode ? .white : .g9L)
                                    .frame(height: 80)
                                    .padding(8)
                                    .background(isDarkMode ? Color.white.opacity(0.1) : Color.g0L)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isDarkMode ? Color.white.opacity(0.3) : Color.g3L, lineWidth: 1)
                                    )
                                
                                // 提交按钮
                                Button(action: submitDetailFeedback) {
                                    Text(GLMPLanguage.feedback_submit)
                                        .font(.avenirButton2Medium)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.mainColor)
                                        .cornerRadius(12)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                } else {
                    // 感谢消息（保持相同高度）
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                            
                            Text(GLMPLanguage.feedback_thanks)
                                .font(.avenirBodyMedium)
                                .foregroundColor(isDarkMode ? .white.opacity(0.8) : .g7L)
                        }
                        Spacer()
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .padding(16)
        .background(isDarkMode ? Color.white.opacity(0.1) : Color.gwL)
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.3), value: showDetailInput)
        .animation(.easeInOut(duration: 0.3), value: showThanks)
    }
    
    // MARK: - Actions
    
    private func handleFeedback(_ type: FeedbackType) {
        selectedFeedback = type
        
        // 触发埋点
        let eventName: String
        if type == .helpful {
            eventName = "\(analysisType.rawValue)_feedback_helpful_click"
        } else {
            eventName = "\(analysisType.rawValue)_feedback_not_helpful_click"
        }
        
        let parameters: [String: Any] = [
            GLT_PARAM_ID: recordId,
            GLT_PARAM_STRING1: score,
            GLT_PARAM_TYPE: type.rawValue,
            GLT_PARAM_TIME: Date().timeIntervalSince1970
        ]
        
        GL().Tracking_Event(eventName, parameters: parameters)
        
        // 如果是负面反馈，展开详细输入框
        if type == .notHelpful {
            withAnimation {
                showDetailInput = true
            }
        } else {
            // 正面反馈直接显示感谢
            showThankYouMessage()
        }
    }
    
    private func submitDetailFeedback() {
        // 触发详细反馈埋点
        let eventName = "\(analysisType.rawValue)_feedback_detail_click"
        let parameters: [String: Any] = [
            GLT_PARAM_ID: recordId,
            GLT_PARAM_STRING1: score,
            GLT_PARAM_TYPE: selectedFeedback?.rawValue ?? "unknown",
            GLT_PARAM_CONTENT: feedbackDetail,
            GLT_PARAM_TIME: Date().timeIntervalSince1970
        ]
        
        GL().Tracking_Event(eventName, parameters: parameters)
        
        // 显示感谢消息
        showThankYouMessage()
    }
    
    private func showThankYouMessage() {
        withAnimation {
            showDetailInput = false
            showThanks = true
        }
    }
}

// MARK: - Supporting Views

/// 反馈按钮
private struct FeedbackButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    var isDarkMode: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                
                Text(text)
                    .font(.avenirBodyMedium)
            }
            .foregroundColor(isSelected ? .white : (isDarkMode ? .white.opacity(0.8) : .g7L))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.mainColor : (isDarkMode ? Color.white.opacity(0.1) : Color.g0L))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mainColor : (isDarkMode ? Color.white.opacity(0.3) : Color.g3L), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ResultFeedbackView(
            recordId: "test-123",
            score: "85",
            analysisType: .makeup
        )
        
        ResultFeedbackView(
            recordId: "test-456",
            score: "75",
            analysisType: .product
        )
    }
    .padding()
    .background(Color.mainBG)
}

