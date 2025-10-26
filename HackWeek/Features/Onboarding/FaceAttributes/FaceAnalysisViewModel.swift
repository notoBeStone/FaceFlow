//
//  FaceAnalysisViewModel.swift
//  HackWords
//
//  Created by Claude on 2025/10/26.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

@MainActor
class FaceAnalysisViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isAnalyzing = false
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let faceAnalysisPrompt: String
    
    // MARK: - Initialization
    
    init() {
        self.faceAnalysisPrompt = Self.loadPrompt(filename: "FaceAnalysis")
    }
    
    // MARK: - Public Methods
    
    /// 分析人脸图片，返回面部属性
    func analyzeFace(_ image: UIImage) async throws -> FaceAnalysisResult {
        isAnalyzing = true
        progress = 0.0
        defer { isAnalyzing = false }
        
        do {
            // 1. 压缩图片（最大边长 1024，JPEG 质量 0.8 - 面部分析需要更高质量）
            progress = 0.1
            guard let imageData = compressImage(image, maxSize: 1024, quality: 0.8) else {
                throw FaceAnalysisError.imageProcessingFailed
            }
            
            debugPrint("✅ 图片压缩完成，大小: \(imageData.count) bytes")
            
            // 2. 上传图片到 S3 获取 URL
            progress = 0.2
            let imageUrl = try await TemplateAPI.S3.upload(data: imageData, fileExtension: "jpg")
            debugPrint("✅ 图片上传成功：\(imageUrl)")
            
            // 3. 构建消息
            progress = 0.3
            let messages = [
                ChatGPTMessage(
                    messageId: 1,
                    role: .system,
                    content: faceAnalysisPrompt,
                    imageUrl: nil
                ),
                ChatGPTMessage(
                    messageId: 2,
                    role: .user,
                    content: nil,
                    imageUrl: imageUrl
                )
            ]
            
            // 4. 调用 GPT-4 Vision API
            progress = 0.4
            debugPrint("🤖 开始调用 GPT-4 Vision API...")
            let resultJSON = try await TemplateAPI.ChatGPT.llmCompletion(
                messages,
                configuration: nil,
                responseFormat: nil
            )
            
            progress = 0.7
            debugPrint("📝 AI 返回结果：\(resultJSON)")
            
            // 5. 提取纯 JSON（移除可能的 markdown 代码块）
            let cleanJSON = extractJSON(from: resultJSON)
            debugPrint("🧹 清洗后的 JSON：\(cleanJSON)")
            
            // 6. 解析 JSON
            progress = 0.8
            guard let jsonData = cleanJSON.data(using: .utf8) else {
                throw FaceAnalysisError.invalidJSONResponse
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(FaceAnalysisResult.self, from: jsonData)
            
            // 7. 验证结果有效性
            progress = 0.9
            guard result.isValid() else {
                debugPrint("⚠️ API 返回了无效的属性值")
                throw FaceAnalysisError.invalidAttributeValues
            }
            
            progress = 1.0
            debugPrint("✅ 面部分析完成")
            debugPrint("📊 分析结果: \(result)")
            
            return result
            
        } catch let error as FaceAnalysisError {
            errorMessage = error.localizedDescription
            debugPrint("❌ 面部分析失败：\(error)")
            throw error
        } catch {
            errorMessage = error.localizedDescription
            debugPrint("❌ 面部分析失败：\(error)")
            throw FaceAnalysisError.analysisFailedWith(error)
        }
    }
    
    /// 保存分析结果到数据库
    func saveAnalysisResult(_ result: FaceAnalysisResult, modelContext: ModelContext) async throws {
        // 获取或创建 UserFaceAttributes
        let descriptor = FetchDescriptor<UserFaceAttributes>()
        let existingAttributes = try modelContext.fetch(descriptor)
        
        let attributes: UserFaceAttributes
        if let existing = existingAttributes.first {
            attributes = existing
        } else {
            attributes = UserFaceAttributes()
            modelContext.insert(attributes)
        }
        
        // 更新从 API 获取的属性
        attributes.faceShape = result.faceShape
        attributes.cheekboneProminence = result.cheekboneProminence
        attributes.jawlineType = result.jawlineType
        attributes.chinShape = result.chinShape
        attributes.eyeSize = result.eyeSize
        attributes.eyeShape = result.eyeShape
        attributes.eyeDistance = result.eyeDistance
        attributes.eyebrowShape = result.eyebrowShape
        attributes.noseLength = result.noseLength
        attributes.noseWidth = result.noseWidth
        attributes.lipsThickness = result.lipsThickness
        attributes.lipsShape = result.lipsShape
        attributes.skinTone = result.skinTone
        attributes.skinBlemishes = result.skinBlemishes
        
        attributes.updatedAt = Date()
        
        try modelContext.save()
        
        debugPrint("✅ 面部属性已保存到数据库")
        debugPrint("📊 保存的属性: \(attributes.getAllTags())")
    }
    
    // MARK: - Private Methods
    
    /// 提取纯 JSON（移除 markdown 代码块等额外内容）
    private func extractJSON(from text: String) -> String {
        // 如果已经是纯 JSON，直接返回
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{") && trimmed.hasSuffix("}") {
            return trimmed
        }
        
        // 尝试提取 markdown 代码块中的 JSON
        let patterns = [
            "```json\\s*\\n([\\s\\S]*?)\\n```",
            "```\\s*\\n([\\s\\S]*?)\\n```"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let extracted = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                debugPrint("🔍 从 markdown 代码块中提取到 JSON")
                return extracted
            }
        }
        
        // 尝试查找第一个 { 和最后一个 } 之间的内容
        if let firstBrace = text.firstIndex(of: "{"),
           let lastBrace = text.lastIndex(of: "}") {
            let jsonPart = String(text[firstBrace...lastBrace])
            debugPrint("🔍 通过大括号提取到 JSON")
            return jsonPart
        }
        
        // 如果都失败了，返回原文本
        debugPrint("⚠️ 无法提取 JSON，返回原文本")
        return text
    }
    
    /// 加载 Prompt 文件
    private static func loadPrompt(filename: String) -> String {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "text"),
              let content = try? String(contentsOf: url) else {
            debugPrint("⚠️ 无法加载 Prompt 文件: \(filename).text")
            return ""
        }
        return content
    }
    
    /// 压缩图片
    private func compressImage(_ image: UIImage, maxSize: CGFloat = 1024, quality: CGFloat = 0.8) -> Data? {
        let size = image.size
        
        // 计算新尺寸
        var newSize = size
        if size.width > maxSize || size.height > maxSize {
            let ratio = size.width / size.height
            if ratio > 1 {
                newSize = CGSize(width: maxSize, height: maxSize / ratio)
            } else {
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

// MARK: - Error Types

enum FaceAnalysisError: LocalizedError {
    case imageProcessingFailed
    case uploadFailed(Error)
    case invalidJSONResponse
    case invalidAttributeValues
    case analysisFailedWith(Error)
    case noFaceDetected
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .uploadFailed(let error):
            return "Failed to upload image: \(error.localizedDescription)"
        case .invalidJSONResponse:
            return "Invalid response from AI"
        case .invalidAttributeValues:
            return "AI returned invalid attribute values"
        case .analysisFailedWith(let error):
            return "Analysis failed: \(error.localizedDescription)"
        case .noFaceDetected:
            return "No face detected in the image"
        }
    }
}

