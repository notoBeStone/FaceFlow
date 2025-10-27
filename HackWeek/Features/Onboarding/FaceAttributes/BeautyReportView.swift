//
//  BeautyReportView.swift
//  HackWords
//
//  Created by Claude on 2025/10/26.
//

import SwiftUI
import GLUtils
import GLMP
import GLTrackingExtension

/// 美妆报告页面 - 显示遮盖的占位符
struct BeautyReportView: View {
    let faceImage: UIImage?
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .frame(height: GLScreenHeight)

            
            ScrollView {
                VStack(spacing: 0) {
                    // 顶部人脸图片
                    if let faceImage = faceImage {
                        Image(uiImage: faceImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 340)
                            .clipped()
                            .mask(
                                // 渐变遮罩 - 让图片从中间到底部逐渐透明
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    VStack(spacing: 32) {
                        // 标题
                        Text("Your Beauty Report")
                            .font(Font.custom("Avenir", size: 28))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                            .frame(width: 335, alignment: .top)
                        
                        // Face Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Face")
                            singleCard(title: "Face Shape", iconName: "onboarding_faceshape")
                            HStack(spacing: 12) {
                                reportCard(title: "Cheekbones", iconName: "onboarding_checkbones")
                                reportCard(title: "Jawlines", iconName: "onboarding_jawlines")
                            }
                            .padding(.horizontal, 16)
                            singleCard(title: "Chin Shape", iconName: "onboarding_chinshape")
                        }
                        
                        // Facial Features Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Facial Features")
                            HStack(spacing: 12) {
                                reportCard(title: "Eye Size", iconName: "onboarding_eyesize")
                                reportCard(title: "Eye Shape", iconName: "onboarding_eyeshape")
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
                .frame(width: GLScreenWidth)
            }
            .scrollDisabled(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 底部按钮
            VStack {
                Spacer()
                
                Button(action: {
                    // Continue 点击埋点
                    GLMPTracking.tracking("onboarding_report_continue_click")
                    onContinue()
                }) {
                    Text("View Full Report")
                        .font(Font.custom("Avenir", size: 18)
                            .weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF4D8E"),
                                    Color(hex: "C44DE5")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 页面曝光埋点
            GLMPTracking.tracking("onboarding_report_exposure")
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(Font.custom("Avenir", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 16)
    }
    
    private func singleCard(title: String, iconName: String) -> some View {
        reportCard(title: title, iconName: iconName)
            .padding(.horizontal, 16)
    }
    
    // MARK: - Report Card
    
    private func reportCard(title: String, iconName: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(Font.custom("Avenir", size: 16)
                        .weight(.medium))
                    .foregroundColor(Color.white)
                
                // 遮盖的内容条
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity, minHeight: 22, maxHeight: 22)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.32, green: 0.29, blue: 0.37), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.36, green: 0.29, blue: 0.34), location: 1.00)
                            ],
                            startPoint: UnitPoint(x: 0, y: 0.5),
                            endPoint: UnitPoint(x: 1, y: 0.5)
                        )
                    )
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.86, green: 0.54, blue: 0.73).opacity(0.1), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.83, green: 0.47, blue: 0.99).opacity(0.1), location: 1.00)
                ],
                startPoint: UnitPoint(x: 0, y: 0.5),
                endPoint: UnitPoint(x: 1, y: 0.5)
            )
        )
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    BeautyReportView(faceImage: .init(named: "vip_header")) {
        debugPrint("Continue tapped")
    }
}
#endif

