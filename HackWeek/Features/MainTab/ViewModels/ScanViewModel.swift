//
//  ScanViewModel.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

@MainActor
class ScanViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var makeupRecords: [ScanRecord] = []
    @Published var productRecords: [ScanRecord] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var recognitionFailed = false
    @Published var failedImage: UIImage?
    @Published var failedReason = ""
    @Published var failedSuggestions = ""
    
    // MARK: - Private Properties
    
    private let makeupPrompt: String
    private let productPrompt: String
    
    // MARK: - Initialization
    
    init() {
        // 加载 Prompt 文件
        self.makeupPrompt = Self.loadPrompt(filename: "Makeup")
        self.productPrompt = Self.loadPrompt(filename: "Product")
    }
    
    // MARK: - Public Methods
    
    /// 分析图片
    /// - Returns: 成功返回保存的记录，失败返回 nil
    func analyzeImage(_ image: UIImage, scanType: ScanType, modelContext: ModelContext) async -> ScanRecord? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. 压缩图片（最大边长 720，JPEG 质量 0.7）
            guard let imageData = compressImage(image, maxSize: 720, quality: 0.7) else {
                throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
            }
            
            // 2. 上传图片到 S3 获取 URL
            let imageUrl = try await TemplateAPI.S3.upload(data: imageData, fileExtension: "jpg")
            print("✅ 图片上传成功：\(imageUrl)")
            
            // 3. 构建消息
            let prompt = scanType == .makeup ? makeupPrompt : productPrompt
            let messages = [
                ChatGPTMessage(
                    messageId: 1,
                    role: .system,
                    content: prompt,
                    imageUrl: nil
                ),
                ChatGPTMessage(
                    messageId: 2,
                    role: .user,
                    content: nil,
                    imageUrl: imageUrl
                )
            ]
            
            // 4. 调用 AI API（使用 gpt-4o 模型以获得更好的联网搜索能力）
            let config = GPTConfig(
                model: .gpt4o,           // 使用 gpt-4o，它有更强的联网搜索能力
                maxTokens: 2000,         // 增加 token 数以获得更完整的成分列表
                temperature: 0.7         // 降低温度以获得更准确的结果
            )
            let resultJSON = try await TemplateAPI.ChatGPT.llmCompletion(
                messages,
                configuration: config,
                responseFormat: nil
            )
            
            print("📝 AI 返回结果：\(resultJSON)")
            
            // 6. 提取纯 JSON（移除可能的 markdown 代码块）
            let cleanJSON = extractJSON(from: resultJSON)
            print("🧹 清洗后的 JSON：\(cleanJSON)")
            
            // 7. 验证 JSON 格式
            guard let jsonData = cleanJSON.data(using: .utf8) else {
                throw NSError(domain: "JSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
            }
            
            // 8. 验证 JSON 可以解析
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                print("✅ JSON 解析成功：\(jsonObject)")
            } catch {
                print("❌ JSON 解析失败：\(error)")
                print("📝 原始返回：\(resultJSON)")
                throw NSError(domain: "JSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON: \(error.localizedDescription)"])
            }
            
            // 9. 检查是否识别失败（评分为 N/A）
            if scanType == .product {
                // 尝试解析产品结果
                if let result = try? JSONDecoder().decode(ProductAnalysisResult.self, from: jsonData) {
                    if result.score == "N/A" {
                        // 识别失败，设置失败状态并返回 nil
                        print("⚠️ 产品识别失败：Score = N/A")
                        recognitionFailed = true
                        failedImage = image
                        failedReason = result.summary
                        failedSuggestions = result.suggestions
                        return nil
                    }
                }
            } else if scanType == .makeup {
                // 妆容评分也可能返回 N/A（虽然不太常见）
                if let result = try? JSONDecoder().decode(MakeupAnalysisResult.self, from: jsonData) {
                    if result.score == "N/A" {
                        print("⚠️ 妆容识别失败：Score = N/A")
                        recognitionFailed = true
                        failedImage = image
                        failedReason = result.review
                        failedSuggestions = result.suggestion
                        return nil
                    }
                }
            }
            
            // 10. 保存记录（只有评分不是 N/A 时才保存）
            let record = ScanRecord(
                scanType: scanType,
                imageData: imageData,
                analysisResultJSON: cleanJSON
            )
            
            modelContext.insert(record)
            try modelContext.save()
            print("✅ 记录保存成功")
            
            // 11. 刷新列表
            fetchRecords(modelContext: modelContext)
            
            // 12. 返回保存的记录
            return record
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ 分析图片失败：\(error)")
            return nil
        }
    }
    
    /// 删除记录
    func deleteRecord(_ record: ScanRecord, modelContext: ModelContext) {
        modelContext.delete(record)
        try? modelContext.save()
        fetchRecords(modelContext: modelContext)
    }
    
    /// 刷新记录列表
    func fetchRecords(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ScanRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let allRecords = try modelContext.fetch(descriptor)
            makeupRecords = allRecords.filter { $0.type == .makeup }
            productRecords = allRecords.filter { $0.type == .product }
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// 提取纯 JSON（移除 markdown 代码块等额外内容）
    /// - Parameter text: 可能包含 markdown 格式的文本
    /// - Returns: 纯 JSON 字符串
    private func extractJSON(from text: String) -> String {
        // 如果已经是纯 JSON，直接返回
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{") && trimmed.hasSuffix("}") {
            return trimmed
        }
        
        // 尝试提取 markdown 代码块中的 JSON
        // 匹配 ```json ... ``` 或 ``` ... ```
        let patterns = [
            "```json\\s*\\n([\\s\\S]*?)\\n```",  // ```json ... ```
            "```\\s*\\n([\\s\\S]*?)\\n```"       // ``` ... ```
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let extracted = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                print("🔍 从 markdown 代码块中提取到 JSON")
                return extracted
            }
        }
        
        // 尝试查找第一个 { 和最后一个 } 之间的内容
        if let firstBrace = text.firstIndex(of: "{"),
           let lastBrace = text.lastIndex(of: "}") {
            let jsonPart = String(text[firstBrace...lastBrace])
            print("🔍 通过大括号提取到 JSON")
            return jsonPart
        }
        
        // 如果都失败了，返回原文本
        print("⚠️ 无法提取 JSON，返回原文本")
        return text
    }
    
    /// 加载 Prompt 文件
    private static func loadPrompt(filename: String) -> String {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "text"),
              let content = try? String(contentsOf: url) else {
            return ""
        }
        return content
    }
    
    /// 压缩图片
    /// - Parameters:
    ///   - image: 原始图片
    ///   - maxSize: 最大边长
    ///   - quality: JPEG 压缩质量 (0.0-1.0)
    /// - Returns: 压缩后的图片数据
    private func compressImage(_ image: UIImage, maxSize: CGFloat = 720, quality: CGFloat = 0.7) -> Data? {
        let size = image.size
        
        // 计算新尺寸
        var newSize = size
        if size.width > maxSize || size.height > maxSize {
            let ratio = size.width / size.height
            if ratio > 1 {
                // 宽度大于高度
                newSize = CGSize(width: maxSize, height: maxSize / ratio)
            } else {
                // 高度大于宽度
                newSize = CGSize(width: maxSize * ratio, height: maxSize)
            }
        }
        
        // 创建新图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 压缩为 JPEG
        return resizedImage?.jpegData(compressionQuality: quality)
    }
}

// MARK: - ChatGPT API
// 使用项目中已有的 ChatGPT API 实现（在 HackWeek/Deprecated/ChatGPTImp.swift 中）
// 通过 TemplateAPI.ChatGPT 调用，该结构体实现了 ChatGPTAPI 协议

