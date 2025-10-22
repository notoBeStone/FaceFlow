//
//  MakeupResultView.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import GLMP

/// 妆容评分结果页面
struct MakeupResultView: View {
    let record: ScanRecord
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSteps: Set<Int> = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 图片
                    if let image = record.thumbnailImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(16)
                    }
                    
                    // 总评分和整体评价
                    if let result = record.makeupResult {
                        OverallSummaryCardView(
                            score: result.calculatedScore,
                            harmony: result.overallHarmony
                        )
                        
                        // 时间轴式维度展示
                        TimelineStepsView(
                            result: result,
                            expandedSteps: $expandedSteps
                        )
                    }
                    
                    // 日期
                    Text(record.formattedDate)
                        .font(.avenirBodyRoman)
                        .foregroundColor(.g5L)
                        .padding(.top, 8)
                    
                    // 反馈组件
                    if let result = record.makeupResult {
                        ResultFeedbackView(
                            recordId: record.id.uuidString,
                            score: result.calculatedScore,
                            analysisType: .makeup
                        )
                        .padding(.top, 16)
                    }
                }
                .padding(20)
            }
            .background(Color.mainBG)
            .navigationTitle(GLMPLanguage.scan_mode_makeup)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(GLMPLanguage.text_done) {
                        dismiss()
                    }
                    .foregroundColor(.mainColor)
                }
            }
        }
    }
}

/// 总评分和整体评价合并卡片
private struct OverallSummaryCardView: View {
    let score: String
    let harmony: String
    
    var body: some View {
        VStack(spacing: 20) {
            // 评分部分
            VStack(spacing: 8) {
                if score == "N/A" {
                    Text(score)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.g5L)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(score)
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.mainColor)
                        
                        Text("/100")
                            .font(.avenirTitle3Heavy)
                            .foregroundColor(.g5L)
                    }
                }
                
                Text(GLMPLanguage.scan_makeup_overall_score)
                    .font(.avenirBodyMedium)
                    .foregroundColor(.g6L)
            }
            
            // 分隔线
            Divider()
                .padding(.horizontal, 20)
            
            // 整体评价
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(.mainColor)
                    
                    Text(GLMPLanguage.scan_makeup_harmony)
                        .font(.avenirBodyMedium)
                        .foregroundColor(.g8L)
                }
                
                Text(harmony)
                    .font(.avenirBodyRoman)
                    .foregroundColor(.g7L)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gwL)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mainColor.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

/// 时间轴式步骤展示
private struct TimelineStepsView: View {
    let result: MakeupAnalysisResult
    @Binding var expandedSteps: Set<Int>
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(result.dimensionsInOrder.enumerated()), id: \.offset) { index, item in
                TimelineStepRow(
                    stepNumber: index + 1,
                    titleKey: item.title,
                    icon: item.icon,
                    dimension: item.dimension,
                    isExpanded: expandedSteps.contains(index),
                    isLast: index == result.dimensionsInOrder.count - 1,
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if expandedSteps.contains(index) {
                                expandedSteps.remove(index)
                            } else {
                                expandedSteps.insert(index)
                            }
                        }
                    }
                )
            }
        }
    }
}

/// 时间轴单个步骤行
private struct TimelineStepRow: View {
    let stepNumber: Int
    let titleKey: String
    let icon: String
    let dimension: MakeupDimensionReview
    let isExpanded: Bool
    let isLast: Bool
    let onTap: () -> Void
    
    // 根据评分获取颜色
    private var scoreColor: Color {
        guard let score = dimension.numericScore else { return .g5L }
        if score >= 85 { return .green }
        if score >= 70 { return .mainColor }
        if score >= 60 { return .orange }
        return .red
    }
    
    var body: some View {
        StepCardView(
            titleKey: titleKey,
            icon: icon,
            dimension: dimension,
            isExpanded: isExpanded,
            scoreColor: scoreColor,
            onTap: onTap
        )
        .padding(.bottom, isLast ? 0 : 12)
    }
}

/// 步骤卡片
private struct StepCardView: View {
    let titleKey: String
    let icon: String
    let dimension: MakeupDimensionReview
    let isExpanded: Bool
    let scoreColor: Color
    let onTap: () -> Void
    
    // 通过反射获取标题文本
    private var title: String {
        let mirror = Mirror(reflecting: GLMPLanguage.self)
        for child in mirror.children {
            if let label = child.label, label == titleKey {
                return child.value as? String ?? titleKey
            }
        }
        // 如果反射失败，使用静态方法
        switch titleKey {
        case "scan_makeup_base": return GLMPLanguage.scan_makeup_base
        case "scan_makeup_contouring": return GLMPLanguage.scan_makeup_contouring
        case "scan_makeup_blush": return GLMPLanguage.scan_makeup_blush
        case "scan_makeup_eyemakeup": return GLMPLanguage.scan_makeup_eyemakeup
        case "scan_makeup_eyebrows": return GLMPLanguage.scan_makeup_eyebrows
        case "scan_makeup_lips": return GLMPLanguage.scan_makeup_lips
        default: return titleKey
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 卡片头部（始终可见）
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // 图标
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(scoreColor)
                        .frame(width: 32)
                    
                    // 标题
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.avenirTitle3Heavy)
                            .foregroundColor(.g9L)
                        
                        // 评分
                        HStack(spacing: 6) {
                            Text(GLMPLanguage.scan_makeup_score_label)
                                .font(.avenirCaption())
                                .foregroundColor(.g5L)
                            
                            Text(dimension.score)
                                .font(.avenirBodyHeavy)
                                .foregroundColor(scoreColor)
                            
                            // 评分进度条
                            if let numericScore = dimension.numericScore {
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.g2L)
                                            .frame(height: 4)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(scoreColor)
                                            .frame(width: geometry.size.width * CGFloat(numericScore / 100), height: 4)
                                    }
                                }
                                .frame(height: 4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 展开/折叠图标
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.g5L)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
                .background(Color.gwL)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 展开内容
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // 评价
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dimension.review)
                            .font(.avenirBodyRoman)
                            .foregroundColor(.g7L)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    
                    // 建议（如果有）
                    if let suggestion = dimension.suggestion {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                                
                                Text(GLMPLanguage.scan_makeup_suggestion)
                                    .font(.avenirBodyMedium)
                                    .foregroundColor(.g7L)
                            }
                            
                            Text(suggestion)
                                .font(.avenirBodyRoman)
                                .foregroundColor(.g7L)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(Color.gwL)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.gwL)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let record = ScanRecord(
        scanType: .makeup,
        imageData: Data(),
        analysisResultJSON: """
        {
            "BaseMakeup": {
                "Score": "88",
                "Review": "Generally well-applied with even coverage. Foundation provides a smooth, natural finish with good face-neck color match.",
                "Suggestion": "Use setting spray to prevent separation around nose area. Consider a lighter hand around the T-zone."
            },
            "Contouring": {
                "Score": "82",
                "Review": "Good placement and blending. Creates natural shadows that enhance facial structure without looking harsh."
            },
            "Blush": {
                "Score": "90",
                "Review": "Natural and well-placed on the apples of the cheeks. Perfect flush that complements skin tone beautifully."
            },
            "EyeMakeup": {
                "Score": "75",
                "Review": "Eyeshadow is well blended with nice color choices. Good depth in the crease. Eyeliner shows some unevenness and could use better symmetry between both eyes.",
                "Suggestion": "Practice eyeliner application using small strokes and connecting them. Use tape as a guide for wings to ensure symmetry."
            },
            "Eyebrows": {
                "Score": "92",
                "Review": "Excellent natural hair strokes with great shape for the face. Color matches hair perfectly with soft, blended edges."
            },
            "Lips": {
                "Score": "85",
                "Review": "Even application with well-defined edges. Lip color coordinates nicely with the overall makeup look."
            },
            "OverallHarmony": "Well-executed makeup with good color coordination across all elements. The natural aesthetic is cohesive and enhances your features beautifully. With minor refinements to eye makeup symmetry, this would be a near-perfect look."
        }
        """
    )
    return MakeupResultView(record: record)
}
