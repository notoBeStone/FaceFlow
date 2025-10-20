//
//  WelcomePage.swift
//  HackWords
//
//  Created by Claude on 2025/10/17.
//

import SwiftUI

/// 欢迎页面 Props
struct WelcomePageProps {
    /// 页面消失回调
    let onDismiss: () -> Void
}

/// 欢迎页面
struct WelcomePage: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = WelcomePageProps
    let props: ComponentProps
    
    var pageName: String { "welcome_page" }
    
    var pageTrackingParams: [String: Any]? {
        ["type": "first_launch"]
    }
    
    // MARK: - Environment
    @Environment(\.tracking) private var tracking
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景色：浅蓝灰色 #F5FAFF
            Color(red: 0.96, green: 0.98, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部状态栏空间
                Spacer()
                    .frame(height: 44)
                
                // Logo 图标区域
                ZStack {
                    // 蓝色渐变圆形背景
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.8),
                                    Color.blue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // 鱼图标
                    Image(systemName: "fish.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                
                Spacer()
                    .frame(height: 50)
                
                // 标题文案
                Text("Welcome to Your\nFish & Aquarium Journey!")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(Color(hex: 0x1A1A1A))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 20)
                
                // 描述文案（带加粗关键词）
                descriptionText
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 36)
                
                // 水族箱插图（使用水滴图标）
                ZStack {
                    // 背景装饰圆
                    Circle()
                        .fill(Color.blue.opacity(0.08))
                        .frame(width: 240, height: 240)
                    
                    // 水滴图标
                    Image(systemName: "drop.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue.opacity(0.4))
                }
                .frame(height: 227)
                
                Spacer()
                
                // 底部按钮
                Button(action: handleGetStarted) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .medium))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: 0x1E90FF))
                    .cornerRadius(40)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 34) // 底部安全区域
            }
        }
    }
    
    // MARK: - Description Text
    
    /// 描述文案（关键词加粗）
    private var descriptionText: some View {
        let fullText = "Make aquarium care easy with personalized guides, health check, and instant AI help for all your fish and plant needs."
        
        // 使用 AttributedString 实现加粗效果
        let attributedString: AttributedString = {
            var attrString = AttributedString(fullText)
            
            // 设置基础字体和颜色
            attrString.font = .system(size: 16)
            attrString.foregroundColor = Color(hex: 0x595959)
            
            // 加粗 "personalized guides"
            if let range = attrString.range(of: "personalized guides") {
                attrString[range].font = .system(size: 16, weight: .semibold)
            }
            
            // 加粗 "health check"
            if let range = attrString.range(of: "health check") {
                attrString[range].font = .system(size: 16, weight: .semibold)
            }
            
            // 加粗 "instant AI"
            if let range = attrString.range(of: "instant AI") {
                attrString[range].font = .system(size: 16, weight: .semibold)
            }
            
            return attrString
        }()
        
        return Text(attributedString)
    }
    
    // MARK: - Actions
    
    /// 处理"开始"按钮点击
    private func handleGetStarted() {
        // 埋点追踪
        tracking("welcome_get_started_click", [
            "type": "action",
            "from": "welcome_page"
        ])
        
        // 触发消失回调
        props.onDismiss()
    }
}

// MARK: - Color Extension
// 注意：Color(hex:) 扩展已在 GLUtils Pod 中定义

// MARK: - Preview

#Preview {
    WelcomePage(props: WelcomePageProps(onDismiss: {
        print("Welcome page dismissed")
    }))
}

