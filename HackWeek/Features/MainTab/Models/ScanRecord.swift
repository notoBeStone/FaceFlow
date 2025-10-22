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

/// 妆容评分结果
struct MakeupAnalysisResult: Codable {
    let score: String
    let review: String
    let suggestion: String
    
    enum CodingKeys: String, CodingKey {
        case score = "Score"
        case review = "Review"
        case suggestion = "Suggestion"
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
            print("⚠️ 类型不匹配：当前类型是 \(scanType)")
            return nil
        }
        
        guard let data = analysisResultJSON.data(using: .utf8) else {
            print("❌ JSON 字符串转 Data 失败")
            return nil
        }
        
        do {
            let result = try JSONDecoder().decode(MakeupAnalysisResult.self, from: data)
            print("✅ 妆容结果解析成功：Score=\(result.score)")
            return result
        } catch {
            print("❌ 妆容结果解析失败：\(error)")
            print("📝 原始 JSON：\(analysisResultJSON)")
            return nil
        }
    }
    
    /// 产品分析结果（仅当类型为 product 时）
    var productResult: ProductAnalysisResult? {
        guard type == .product else {
            print("⚠️ 类型不匹配：当前类型是 \(scanType)")
            return nil
        }
        
        guard let data = analysisResultJSON.data(using: .utf8) else {
            print("❌ JSON 字符串转 Data 失败")
            return nil
        }
        
        do {
            let result = try JSONDecoder().decode(ProductAnalysisResult.self, from: data)
            print("✅ 产品结果解析成功：Score=\(result.score)")
            return result
        } catch {
            print("❌ 产品结果解析失败：\(error)")
            print("📝 原始 JSON：\(analysisResultJSON)")
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

