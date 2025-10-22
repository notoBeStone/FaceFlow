//
//  ProductResultView.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import GLMP

/// 产品扫描结果页面
struct ProductResultView: View {
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
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(16)
                    }
                    
                    // 结果
                    if let result = record.productResult {
                        // 安全评分
                        SafetyScoreCardView(score: result.score)
                        
                        // 摘要
                        ResultSectionView(
                            title: GLMPLanguage.scan_result_summary,
                            content: result.summary,
                            icon: "doc.text.fill"
                        )
                        
                        // 建议
                        ResultSectionView(
                            title: GLMPLanguage.scan_result_suggestion,
                            content: result.suggestions,
                            icon: "lightbulb.fill"
                        )
                        
                        // 成分列表
                        if !result.ingredients.isEmpty {
                            IngredientsListView(ingredients: result.ingredients)
                        }
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
            .navigationTitle(GLMPLanguage.scan_mode_product)
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

/// 安全评分卡片
private struct SafetyScoreCardView: View {
    let score: String
    
    private var scoreValue: Int {
        Int(score) ?? 0
    }
    
    private var scoreColor: Color {
        if scoreValue >= 80 { return .green }
        if scoreValue >= 60 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(GLMPLanguage.scan_result_score)
                .font(.avenirBodyMedium)
                .foregroundColor(.g6L)
            
            if score == "N/A" {
                Text(score)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.g5L)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(score)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(scoreColor)
                    
                    Text("/100")
                        .font(.avenirTitle3Heavy)
                        .foregroundColor(.g5L)
                }
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

/// 成分列表视图
private struct IngredientsListView: View {
    let ingredients: [ProductAnalysisResult.Ingredient]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16))
                    .foregroundColor(.mainColor)
                
                Text(GLMPLanguage.scan_result_ingredients)
                    .font(.avenirTitle3Heavy)
                    .foregroundColor(.g9L)
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.g5L)
                }
            }
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(ingredients) { ingredient in
                        IngredientRowView(ingredient: ingredient)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.gwL)
        .cornerRadius(12)
    }
}

/// 成分行视图
private struct IngredientRowView: View {
    let ingredient: ProductAnalysisResult.Ingredient
    
    private var riskColor: Color {
        switch ingredient.riskLevel.lowercased() {
        case "low": return .green
        case "medium": return .orange
        case "high": return .red
        default: return .g5L
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ingredient.name)
                    .font(.avenirBodyMedium)
                    .foregroundColor(.g9L)
                
                Spacer()
                
                Text(ingredient.riskLevel)
                    .font(.avenirCaptionRoman)
                    .foregroundColor(riskColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(riskColor.opacity(0.1))
                    .cornerRadius(6)
            }
            
            if !ingredient.possibleSideEffects.isEmpty && ingredient.possibleSideEffects != "None" {
                Text(ingredient.possibleSideEffects)
                    .font(.avenirCaptionRoman)
                    .foregroundColor(.g6L)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let record = ScanRecord(
        scanType: .product,
        imageData: Data(),
        analysisResultJSON: """
        {
            "Score": "85",
            "Summary": "The product contains mainly safe ingredients. One potential allergen (Fragrance) was found but in low concentration.",
            "Suggestions": "Suitable for general use. Users with fragrance allergies should exercise caution.",
            "Ingredients": [
                {
                    "Name": "Aqua (Water)",
                    "RiskLevel": "Low",
                    "PossibleSideEffects": "None"
                },
                {
                    "Name": "Fragrance (Parfum)",
                    "RiskLevel": "Medium",
                    "PossibleSideEffects": "Potential skin irritant/allergen"
                }
            ]
        }
        """
    )
    return ProductResultView(record: record)
}

