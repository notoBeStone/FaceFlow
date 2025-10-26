//
//  FaceAnalysisLoadingView.swift
//  HackWords
//
//  Created by Claude on 2025/10/26.
//

import SwiftUI
import SwiftData

/// 面部分析加载页面
struct FaceAnalysisLoadingView: View {
    @StateObject private var viewModel = FaceAnalysisViewModel()
    @Environment(\.modelContext) private var modelContext
    
    let faceImage: UIImage?
    let onComplete: () -> Void
    let onError: (String) -> Void
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 标题
                Text(GLMPLanguage.faceAttributes_loading_title)
                    .font(Font.custom("Avenir", size: 24).weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                    .frame(width: 343)
                
                Spacer()
                    .frame(height: 100)
                
                // 进度圆环
                ZStack {
                    // 背景圆环
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    // 进度圆环（渐变色）
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1, green: 0.3, blue: 0.56),
                                    Color(red: 0.655, green: 0.098, blue: 0.824)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: viewModel.progress)
                    
                    // 进度百分比文字
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(Font.custom("Avenir", size: 32).weight(.medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startLoading()
        }
    }
    
    // MARK: - Loading Animation
    
    private func startLoading() {
        Task {
            await performFaceAnalysis()
        }
    }
    
    private func performFaceAnalysis() async {
        // 1. 检查是否有人脸图片
        guard let faceImage = faceImage else {
            debugPrint("⚠️ 没有人脸图片，直接进入结果页")
            await completeAnalysis()
            return
        }
        
        debugPrint("🚀 开始面部分析...")
        
        // 2. 调用 API 分析面部属性（无论成功失败都继续）
        do {
            let result = try await viewModel.analyzeFace(faceImage)
            
            debugPrint("✅ 面部分析完成")
            debugPrint("📊 分析结果: faceShape=\(result.faceShape), eyeShape=\(result.eyeShape)")
            
            // 3. 保存到数据库
            try await viewModel.saveAnalysisResult(result, modelContext: modelContext)
            
            debugPrint("✅ 数据已保存到 SwiftData")
        } catch {
            debugPrint("❌ 面部分析失败: \(error)")
            debugPrint("ℹ️ 但仍然继续进入结果页")
            // 不抛出错误，继续流程
        }
        
        // 4. 无论成功失败，都进入结果页
        await completeAnalysis()
    }
    
    private func completeAnalysis() async {
        // 延迟一下让用户看到 100% 的进度
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 秒
        
        // 完成回调
        await MainActor.run {
            onComplete()
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    FaceAnalysisLoadingView(
        faceImage: nil,
        onComplete: {
            debugPrint("Loading completed")
        },
        onError: { error in
            debugPrint("Error: \(error)")
        }
    )
}
#endif

