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
                    
                    // 评分
                    if let result = record.makeupResult {
                        ScoreCardView(score: result.score)
                        
                        // 评价
                        ResultSectionView(
                            title: GLMPLanguage.scan_result_review,
                            content: result.review,
                            icon: "star.fill"
                        )
                        
                        // 建议
                        ResultSectionView(
                            title: GLMPLanguage.scan_result_suggestion,
                            content: result.suggestion,
                            icon: "lightbulb.fill"
                        )
                    }
                    
                    // 日期
                    Text(record.formattedDate)
                        .font(.avenirBodyRoman)
                        .foregroundColor(.g5L)
                        .padding(.top, 8)
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

/// 评分卡片
private struct ScoreCardView: View {
    let score: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(GLMPLanguage.scan_result_score)
                .font(.avenirBodyMedium)
                .foregroundColor(.g6L)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(score)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.mainColor)
                
                Text("/100")
                    .font(.avenirTitle3Heavy)
                    .foregroundColor(.g5L)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.gwL)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

/// 结果区块视图
private struct ResultSectionView: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.mainColor)
                
                Text(title)
                    .font(.avenirTitle3Heavy)
                    .foregroundColor(.g9L)
            }
            
            Text(content)
                .font(.avenirBodyRoman)
                .foregroundColor(.g7L)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gwL)
        .cornerRadius(12)
    }
}

#Preview {
    let record = ScanRecord(
        scanType: .makeup,
        imageData: Data(),
        analysisResultJSON: """
        {
            "Score": "85",
            "Review": "Your makeup looks great! The foundation is well blended and the color matching is excellent.",
            "Suggestion": "Consider adding a bit more blush for a healthier glow. The eyebrow shape could be slightly adjusted to better frame your eyes."
        }
        """
    )
    return MakeupResultView(record: record)
}

