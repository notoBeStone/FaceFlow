//
//  ProductRecognitionFailedView.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import GLMP

/// 产品识别失败页面
struct ProductRecognitionFailedView: View {
    let image: UIImage
    let reason: String
    let suggestions: String
    let onRetake: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 失败图标
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 20)
                    
                    // 标题
                    VStack(spacing: 8) {
                        Text(GLMPLanguage.scan_recognition_failed_title)
                            .font(.avenirTitle2Heavy)
                            .foregroundColor(.g9L)
                        
                        Text(GLMPLanguage.scan_recognition_failed_subtitle)
                            .font(.avenirBodyRoman)
                            .foregroundColor(.g6L)
                    }
                    
                    // 用户拍摄的照片
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    // AI 返回的原因
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.mainColor)
                            
                            Text(GLMPLanguage.scan_result_summary)
                                .font(.avenirTitle3Heavy)
                                .foregroundColor(.g9L)
                        }
                        
                        Text(reason)
                            .font(.avenirBodyRoman)
                            .foregroundColor(.g7L)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.gwL)
                    .cornerRadius(12)
                    
                    // AI 返回的建议
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.mainColor)
                            
                            Text(GLMPLanguage.scan_result_suggestion)
                                .font(.avenirTitle3Heavy)
                                .foregroundColor(.g9L)
                        }
                        
                        Text(suggestions)
                            .font(.avenirBodyRoman)
                            .foregroundColor(.g7L)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.gwL)
                    .cornerRadius(12)
                    
                    // 通用提示
                    VStack(alignment: .leading, spacing: 16) {
                        Text(GLMPLanguage.scan_recognition_failed_tips_title)
                            .font(.avenirTitle3Heavy)
                            .foregroundColor(.g9L)
                        
                        VStack(spacing: 12) {
                            TipRow(icon: "photo", text: GLMPLanguage.scan_recognition_failed_tip_1)
                            TipRow(icon: "sun.max.fill", text: GLMPLanguage.scan_recognition_failed_tip_2)
                            TipRow(icon: "camera.metering.center.weighted", text: GLMPLanguage.scan_recognition_failed_tip_3)
                            TipRow(icon: "list.bullet.rectangle", text: GLMPLanguage.scan_recognition_failed_tip_4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.gwL)
                    .cornerRadius(12)
                    
                    // 按钮区域
                    VStack(spacing: 12) {
                        // 重新拍摄按钮
                        Button(action: {
                            dismiss()
                            // 延迟一下再打开相机，确保当前页面已关闭
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onRetake()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                
                                Text(GLMPLanguage.scan_recognition_failed_retake)
                                    .font(.avenirBodyHeavy)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.mainColor)
                            .cornerRadius(16)
                        }
                        
                        // 关闭按钮
                        Button(action: {
                            dismiss()
                        }) {
                            Text(GLMPLanguage.scan_recognition_failed_close)
                                .font(.avenirBodyHeavy)
                                .foregroundColor(.g7L)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.g2L)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color.mainBG)
            .navigationTitle(GLMPLanguage.scan_mode_product)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.g7L)
                    }
                }
            }
        }
    }
}

/// 提示行
private struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.mainColor.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.mainColor)
            }
            
            Text(text)
                .font(.avenirBodyRoman)
                .foregroundColor(.g7L)
            
            Spacer()
        }
    }
}

#Preview {
    ProductRecognitionFailedView(
        image: UIImage(systemName: "photo")!,
        reason: "The image is too blurry to read the ingredient list. Please ensure the product label is clearly focused.",
        suggestions: "Please take a clearer photo of the ingredient list with better lighting conditions and ensure the camera is properly focused on the text."
    ) {
        debugPrint("Retake tapped")
    }
}

