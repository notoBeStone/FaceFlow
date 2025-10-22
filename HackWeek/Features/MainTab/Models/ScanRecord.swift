//
//  ScanRecord.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import Foundation
import SwiftData
import UIKit

/// 扫描类型
enum ScanType: String, Codable {
    case makeup = "makeup"     // 自拍妆容
    case product = "product"   // 产品扫描
}

/// 妆容维度评价
struct MakeupDimensionReview: Codable {
    let score: String  // 可以是数字字符串 "85" 或 "N/A"
    let review: String
    let suggestion: String?
    
    enum CodingKeys: String, CodingKey {
        case score = "Score"
        case review = "Review"
        case suggestion = "Suggestion"
    }
    
    /// 获取数字评分（如果是 N/A 则返回 nil）
    var numericScore: Double? {
        Double(score)
    }
}

/// 妆容评分结果
struct MakeupAnalysisResult: Codable {
    let baseMakeup: MakeupDimensionReview
    let contouring: MakeupDimensionReview
    let blush: MakeupDimensionReview
    let eyeMakeup: MakeupDimensionReview
    let eyebrows: MakeupDimensionReview
    let lips: MakeupDimensionReview
    let overallHarmony: String
    
    enum CodingKeys: String, CodingKey {
        case baseMakeup = "BaseMakeup"
        case contouring = "Contouring"
        case blush = "Blush"
        case eyeMakeup = "EyeMakeup"
        case eyebrows = "Eyebrows"
        case lips = "Lips"
        case overallHarmony = "OverallHarmony"
    }
    
    /// 计算总评分（加权平均）
    /// 权重分配：底妆20%、眉毛15%、眼妆25%、修容10%、腮红10%、唇妆10%、高光10%
    var calculatedScore: String {
        // 收集所有维度的评分
        let dimensions: [(dimension: MakeupDimensionReview, weight: Double)] = [
            (baseMakeup, 0.20),     // 底妆 20%
            (eyebrows, 0.15),       // 眉毛 15%
            (eyeMakeup, 0.25),      // 眼妆 25%
            (contouring, 0.15),     // 修容 15%
            (blush, 0.15),          // 腮红 15%
            (lips, 0.10)            // 唇妆 10%
        ]
        
        var totalScore = 0.0
        var totalWeight = 0.0
        
        for (dimension, weight) in dimensions {
            if let score = dimension.numericScore {
                totalScore += score * weight
                totalWeight += weight
            }
        }
        
        // 如果没有任何有效评分，返回 N/A
        guard totalWeight > 0 else {
            return "N/A"
        }
        
        // 计算加权平均分
        let averageScore = totalScore / totalWeight
        return String(format: "%.0f", averageScore)
    }
    
    /// 各维度评价（按化妆步骤顺序）
    var dimensionsInOrder: [(title: String, icon: String, dimension: MakeupDimensionReview)] {
        return [
            ("scan_makeup_base", "paintpalette.fill", baseMakeup),
            ("scan_makeup_contouring", "circle.lefthalf.filled", contouring),
            ("scan_makeup_blush", "heart.fill", blush),
            ("scan_makeup_eyemakeup", "eye.fill", eyeMakeup),
            ("scan_makeup_eyebrows", "line.3.horizontal", eyebrows),
            ("scan_makeup_lips", "mouth.fill", lips)
        ]
    }
}

/// 产品扫描结果
struct ProductAnalysisResult: Codable {
    let score: String
    let summary: String
    let suggestions: String
    let ingredients: [Ingredient]
    
    enum CodingKeys: String, CodingKey {
        case score = "Score"
        case summary = "Summary"
        case suggestions = "Suggestions"
        case ingredients = "Ingredients"
    }
    
    struct Ingredient: Codable, Identifiable {
        var id: String { name }
        let name: String
        let riskLevel: String
        let possibleSideEffects: String
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case riskLevel = "RiskLevel"
            case possibleSideEffects = "PossibleSideEffects"
        }
    }
}

/// 扫描记录数据模型
@Model
final class ScanRecord {
    // MARK: - Properties
    
    /// 唯一标识符
    @Attribute(.unique) var id: UUID
    
    /// 扫描类型
    var scanType: String
    
    /// 图片数据
    var imageData: Data
    
    /// 分析结果 JSON 字符串
    var analysisResultJSON: String
    
    /// 创建时间
    var createdAt: Date
    
    // MARK: - Computed Properties
    
    /// 扫描类型枚举
    var type: ScanType {
        ScanType(rawValue: scanType) ?? .makeup
    }
    
    /// 妆容分析结果（仅当类型为 makeup 时）
    var makeupResult: MakeupAnalysisResult? {
        guard type == .makeup else {
            debugPrint("⚠️ 类型不匹配：当前类型是 \(scanType)")
            return nil
        }
        
        guard let data = analysisResultJSON.data(using: .utf8) else {
            debugPrint("❌ JSON 字符串转 Data 失败")
            return nil
        }
        
        do {
            let result = try JSONDecoder().decode(MakeupAnalysisResult.self, from: data)
            return result
        } catch {
            debugPrint("❌ 妆容结果解析失败：\(error)")
            debugPrint("📝 原始 JSON：\(analysisResultJSON)")
            return nil
        }
    }
    
    /// 产品分析结果（仅当类型为 product 时）
    var productResult: ProductAnalysisResult? {
        guard type == .product else {
            debugPrint("⚠️ 类型不匹配：当前类型是 \(scanType)")
            return nil
        }
        
        guard let data = analysisResultJSON.data(using: .utf8) else {
            debugPrint("❌ JSON 字符串转 Data 失败")
            return nil
        }
        
        do {
            let result = try JSONDecoder().decode(ProductAnalysisResult.self, from: data)
            debugPrint("✅ 产品结果解析成功：Score=\(result.score)")
            return result
        } catch {
            debugPrint("❌ 产品结果解析失败：\(error)")
            debugPrint("📝 原始 JSON：\(analysisResultJSON)")
            return nil
        }
    }
    
    /// 缩略图
    var thumbnailImage: UIImage? {
        UIImage(data: imageData)
    }
    
    /// 格式化的日期字符串
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Initialization
    
    init(scanType: ScanType, imageData: Data, analysisResultJSON: String) {
        self.id = UUID()
        self.scanType = scanType.rawValue
        self.imageData = imageData
        self.analysisResultJSON = analysisResultJSON
        self.createdAt = Date()
    }
}

