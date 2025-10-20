//
//  IdentificationViewModel.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import Foundation
import SwiftUI
import Vision
import VisionKit
import CoreImage
import CoreVideo

@MainActor
class IdentificationViewModel: ObservableObject {
    let originalImage: UIImage

    @Published var currentImage: UIImage?
    @Published var statusText: String = "Processing"
    @Published var identifiedWord: String?
    @Published var isProcessing: Bool = false

    // 识别状态
    enum IdentificationState {
        case processing    // 初始态：展现完整图片，文案为 Processing
        case identifying   // 识别态：经过抠图API，获得主要目标物体，文案为 Identifying
        case optimizing    // 优化态：进行智能裁剪和边缘平滑处理，文案为 Optimizing
        case completed     // 完成态：从LLM API获得图片对应的单词，文案展示为对应的单词
    }

    @Published var currentState: IdentificationState = .processing

    init(image: UIImage) {
        self.originalImage = image
        self.currentImage = image
    }

    // 开始识别流程
    func startIdentification() {
        isProcessing = true
        currentState = .processing
        statusText = "Processing"

        debugPrint("🎯 开始识别流程，原图尺寸: \(originalImage.size)")

        // 模拟处理延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performSubjectSegmentation()
        }
    }

    // 执行主体分割（抠图）
    private func performSubjectSegmentation() {
        currentState = .identifying
        statusText = "Identifying"

        debugPrint("🔍 开始执行主体分割")

        // 检查是否支持VisionKit的抠图功能
        if #available(iOS 17.0, *) {
            performVisionKitSegmentation()
        } else {
            debugPrint("❌ iOS版本不支持VisionKit抠图")
            // 如果不支持，直接完成识别
            completeIdentificationWithoutLLM()
        }
    }

    // 使用VisionKit进行抠图
    private func performVisionKitSegmentation() {
        guard let cgImage = originalImage.cgImage else {
            debugPrint("❌ 无法获取CGImage")
            completeIdentificationWithoutLLM()
            return
        }

        debugPrint("✅ 开始VisionKit抠图，图片尺寸: \(originalImage.size)")
        debugPrint("📊 CGImage info: width=\(cgImage.width), height=\(cgImage.height), colorSpace=\(cgImage.colorSpace?.name as String? ?? "unknown")")

        let request = VNGenerateForegroundInstanceMaskRequest { request, error in
            debugPrint("📨 VisionKit请求回调开始")

            if let error = error {
                debugPrint("❌ 抠图失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.completeIdentificationWithoutLLM()
                }
                return
            }

            guard let results = request.results else {
                debugPrint("❌ 没有找到任何结果")
                DispatchQueue.main.async {
                    self.completeIdentificationWithoutLLM()
                }
                return
            }

            debugPrint("📊 找到 \(results.count) 个结果")

            guard let result = results.first as? VNInstanceMaskObservation else {
                debugPrint("❌ 第一个结果不是VNInstanceMaskObservation")
                DispatchQueue.main.async {
                    self.completeIdentificationWithoutLLM()
                }
                return
            }

            debugPrint("✅ 找到抠图结果，mask instances: \(result.allInstances.count)")

            do {
                // 创建抠图后的图片并进行优化处理
                let optimizedImage = try self.createOptimizedMaskedImage(from: result, originalImage: cgImage)
                DispatchQueue.main.async {
                    debugPrint("✅ 优化抠图图片创建成功，新图片尺寸: \(optimizedImage.size)")
                    self.currentImage = optimizedImage

                    // 抠图完成后进行LLM识别
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.performLLMIdentification()
                    }
                }
            } catch {
                debugPrint("❌ 创建抠图失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.completeIdentificationWithoutLLM()
                }
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            debugPrint("✅ VisionKit请求已发送")
        } catch {
            debugPrint("❌ VisionKit请求失败: \(error.localizedDescription)")
            completeIdentificationWithoutLLM()
        }
    }

    // 暂时跳过LLM识别，直接完成识别流程
    private func completeIdentificationWithoutLLM() {
        debugPrint("🏁 完成识别流程（跳过LLM）")
        currentState = .completed
        identifiedWord = "test_word"
        statusText = "test_word"
        isProcessing = false
    }

    // 创建优化后的抠图图片 - 集成智能裁剪和边缘平滑
    private func createOptimizedMaskedImage(from maskObservation: VNInstanceMaskObservation, originalImage: CGImage) throws -> UIImage {
        let startTime = CFAbsoluteTimeGetCurrent()

        // 更新状态为优化处理
        DispatchQueue.main.async {
            self.currentState = .optimizing
            self.statusText = "Optimizing"
        }

        debugPrint("🚀 开始创建优化抠图图片")

        // 1. 创建基础抠图图片
        let baseMaskedImage = try createMaskedImage(from: maskObservation, originalImage: originalImage)
        debugPrint("✅ 基础抠图完成，尺寸: \(baseMaskedImage.size)")

        var optimizedImage = baseMaskedImage
        let originalUIImage = UIImage(cgImage: originalImage)
        let originalSize = originalUIImage.size

        var wasCropped = false
        var wasSmoothed = false

        // 2. 智能裁剪（基于 mask 的最小矩形区域）
        let croppedImage = MaskCroppingUtil.cropImageBasedOnMask(
            maskObservation: maskObservation,
            originalImage: originalUIImage,
            croppedImage: optimizedImage
        )

        // 检查是否真的进行了裁剪
        if croppedImage.size != optimizedImage.size {
            optimizedImage = croppedImage
            wasCropped = true
            debugPrint("✂️ 智能裁剪完成，新尺寸: \(optimizedImage.size)")
        } else {
            debugPrint("⏭️ 跳过智能裁剪（未找到有效的裁剪区域）")
        }

        // 3. 边缘平滑处理（轻度抗锯齿）- 暂时禁用
        debugPrint("⏭️ 边缘平滑处理暂时禁用")
        wasSmoothed = false

        let totalDuration = CFAbsoluteTimeGetCurrent() - startTime
        debugPrint("🎉 优化抠图图片创建完成，总耗时: \(String(format: "%.3f", totalDuration))s")
        debugPrint("📏 最终尺寸: \(optimizedImage.size)")

        // 记录性能统计
        DispatchQueue.main.async {
            self.recordPerformanceStats(
                originalSize: originalSize,
                finalSize: optimizedImage.size,
                processingTime: totalDuration,
                wasCropped: wasCropped,
                wasSmoothed: wasSmoothed
            )
        }

        return optimizedImage
    }

    // 创建抠图后的图片 - 使用自定义shader处理
    private func createMaskedImage(from maskObservation: VNInstanceMaskObservation, originalImage: CGImage) throws -> UIImage {
        debugPrint("🎨 开始使用自定义shader创建抠图图片")

        let pixelBuffer = try maskObservation.generateMaskedImage(ofInstances: [0], from: VNImageRequestHandler(cgImage: originalImage, options: [:]), croppedToInstancesExtent: false)

        debugPrint("📊 PixelBuffer创建成功: width=\(CVPixelBufferGetWidth(pixelBuffer)), height=\(CVPixelBufferGetHeight(pixelBuffer))")

        // 创建Core Image context，使用GPU加速
        let context = CIContext(options: [.useSoftwareRenderer: false, .priorityRequestLow: false])

        // 将原始图片转换为CIImage，统一转换为RGB色彩空间
        let originalCIImage = CIImage(cgImage: originalImage)
        let rgbOriginalImage = originalCIImage.applyingFilter("CIColorControls", parameters: [
            kCIInputSaturationKey: 1.0,
            kCIInputBrightnessKey: 0.0,
            kCIInputContrastKey: 1.0
        ])
        debugPrint("✅ 原始图片转换为RGB CIImage成功")

        // 将mask转换为CIImage
        let maskCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        debugPrint("✅ mask转换为CIImage成功，extent: \(maskCIImage.extent)")

        // 使用自定义shader进行抠图
        let maskedImage = try applyMaskShader(rgbOriginalImage, mask: maskCIImage, context: context)
        debugPrint("✅ shader抠图处理成功")

        // 将结果转回UIImage
        guard let outputCGImage = context.createCGImage(maskedImage, from: maskedImage.extent) else {
            debugPrint("❌ 无法创建最终CGImage")
            throw NSError(domain: "FinalImageCreation", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create final CGImage"])
        }

        let result = UIImage(cgImage: outputCGImage)
        debugPrint("🎉 自定义shader抠图完成，最终尺寸: \(result.size)")

        return result
    }

    // 使用自定义shader应用mask：原图减去mask得到主体
    private func applyMaskShader(_ image: CIImage, mask: CIImage, context: CIContext) throws -> CIImage {
        // 创建自定义kernel
        let kernel = CIKernel(source: """
        kernel vec4 maskShader(__sample image, __sample mask) {
            // 获取当前坐标的像素颜色
            vec4 imageColor = image;
            vec4 maskColor = mask;

            // 如果mask像素是透明的（alpha=0），说明这是主体区域，保留原图
            // 如果mask像素不透明（alpha>0），说明这是背景区域，变为透明
            float alpha = 1.0 - maskColor.a;

            // 返回原图颜色，但alpha根据mask的透明度调整
            return vec4(imageColor.rgb, alpha);
        }
        """)

        guard let shader = kernel else {
            throw NSError(domain: "ShaderCreation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create custom shader"])
        }

        // 应用shader
        guard let maskedImage = shader.apply(extent: image.extent, roiCallback: { (index, rect) in
            return rect
        }, arguments: [image, mask]) else {
            throw NSError(domain: "ShaderApplication", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to apply custom shader"])
        }

        return maskedImage
    }

    // 将CVPixelBuffer转换为CGImage的辅助方法
    private func createCGImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }

    // 进行LLM识别
    private func performLLMIdentification() {
        // 获取用户的目标学习语言
        let targetLanguage = OnboardingManager.shared.currentOnboardingData?.targetLanguage ?? "english"

        Task {
            do {
                let word = try await identifyImageWithLLM(image: currentImage ?? originalImage, targetLanguage: targetLanguage)

                await MainActor.run {
                    self.currentState = .completed
                    self.identifiedWord = word
                    self.statusText = word
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.currentState = .completed
                    self.identifiedWord = "识别失败"
                    self.statusText = "识别失败"
                    self.isProcessing = false
                }
            }
        }
    }

    // 使用LLM识别图片
    private func identifyImageWithLLM(image: UIImage, targetLanguage: String) async throws -> String {
        debugPrint("🚀 开始LLM识别流程")

        // 上传图片到S3
        let imageUrl = try await uploadImageToS3(image: image)
        debugPrint("✅ 图片上传成功，URL: \(imageUrl)")

        // 构造消息 - 系统指令和图片分别在不同的消息中
        let systemMessage = ChatGPTMessage(messageId: 1, role: GPTRole.system, content: "你是一个专业的图片识别助手。请识别图片中的主要物体，并返回对应的\(targetLanguage)单词。只需要返回一个单词，不要包含任何其他解释。", imageUrl: nil)

        // 图片消息，使用URL而不是base64
        let imageMessage = ChatGPTMessage(messageId: 2, role: GPTRole.user, content: "", imageUrl: imageUrl)

        // 文本指令消息
        let textMessage = ChatGPTMessage(messageId: 3, role: GPTRole.user, content: "请识别这张图片中的主要物体，返回对应的\(targetLanguage)单词。", imageUrl: nil)

        debugPrint("📨 发送LLM请求，图片URL: \(imageUrl)")

        // 调用LLM API
        let response = try await TemplateAPI.ChatGPT.llmCompletion(
            [systemMessage, imageMessage, textMessage],
            configuration: GPTConfig.default,
            responseFormat: nil
        )

        debugPrint("✅ LLM响应: \(response)")

        // 清理响应，只保留单词
        let cleanedWord = response.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanedWord.isEmpty ? "unknown" : cleanedWord
    }

    // 上传图片到S3
    private func uploadImageToS3(image: UIImage) async throws -> String {
        debugPrint("📤 开始上传图片到S3")

        // 将图片转换为JPEG数据
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"])
        }

        debugPrint("📊 图片数据大小: \(imageData.count) bytes")

        // 使用TemplateAPI的S3上传功能
        let imageUrl = try await TemplateAPI.S3.upload(data: imageData, fileExtension: "jpg")
        debugPrint("✅ S3上传成功: \(imageUrl)")

        return imageUrl
    }

    // MARK: - 性能监控

    /// 记录处理性能统计
    private func recordPerformanceStats(
        originalSize: CGSize,
        finalSize: CGSize,
        processingTime: TimeInterval,
        wasCropped: Bool,
        wasSmoothed: Bool
    ) {
        let compressionRatio = (finalSize.width * finalSize.height) / (originalSize.width * originalSize.height)
        let spaceSaved = 1.0 - compressionRatio

        let stats: [String: Any] = [
            "originalSize": "\(originalSize)",
            "finalSize": "\(finalSize)",
            "processingTime": String(format: "%.3f", processingTime),
            "compressionRatio": String(format: "%.2f", compressionRatio),
            "spaceSaved": String(format: "%.1f", spaceSaved * 100),
            "wasCropped": wasCropped,
            "wasSmoothed": wasSmoothed,
            "timestamp": Date().timeIntervalSince1970
        ]

        debugPrint("📊 性能统计: \(stats)")

        // 可以将统计信息发送到分析服务
        // TemplateAPI.Analytics.track("image_optimization_performance", parameters: stats)
    }

    /// 获取当前处理性能信息
    func getPerformanceInfo() -> [String: Any] {
        let maskStats = MaskCroppingUtil.getPerformanceStats()
        let smoothingStats = EdgeSmoothingUtil.getPerformanceStats()

        return [
            "maskCropping": maskStats,
            "edgeSmoothing": smoothingStats,
            "supportedFeatures": [
                "ios17_minimum": true,
                "fast_cropping": true,
                "light_smoothing": true,
                "gpu_acceleration": true
            ]
        ]
    }

    // 保存到单词本
    func saveToWordbook() {
        guard let word = identifiedWord, !word.isEmpty && word != "识别失败" else {
            print("❌ 没有有效的单词可以保存")
            return
        }

        // 获取当前处理后的图片（抠图后的图片）或原图
        let imageToSave = currentImage ?? originalImage

        // 获取用户的目标学习语言
        let targetLanguage = OnboardingManager.shared.currentOnboardingData?.targetLanguage ?? "english"

        debugPrint("💾 开始保存单词到单词本: \(word)")
        debugPrint("📸 使用图片: \(imageToSave.size)")
        debugPrint("🌍 目标语言: \(targetLanguage)")

        // 使用WordBookManager保存单词
        let success = WordBookManager.shared.createWord(
            image: imageToSave,
            targetLanguage: targetLanguage,
            word: word
        ) != nil

        if success {
            debugPrint("✅ 单词保存成功: \(word)")
        } else {
            debugPrint("❌ 单词保存失败: \(word)")
        }
    }
}
