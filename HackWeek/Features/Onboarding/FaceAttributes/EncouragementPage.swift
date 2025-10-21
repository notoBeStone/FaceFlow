//
//  EncouragementPage.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI

/// 阶段性鼓励页面
struct EncouragementPage: View {
    let stage: OnboardingStage
    let onContinue: () -> Void
    
    @State private var showContent = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(hex: "FFE5EE"), Color(hex: "FFF5F7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 内容区域
                VStack(spacing: 32) {
                    // 动画表情符号
                    Text(stage.emoji)
                        .font(.system(size: 80))
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                    
                    VStack(spacing: 16) {
                        // 完成提示
                        Text(GLMPLanguage.faceAttributes_encouragement_awesome)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "FF6B9D"))
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                        
                        // 阶段标题
                        Text(stage.title)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                        
                        // 副标题
                        Text(stage.subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "666666"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                    }
                    
                    // 继续按钮
                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text(GLMPLanguage.common_continue)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FF6B9D"), Color(hex: "FF8FB3")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Color(hex: "FF6B9D").opacity(0.4), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .opacity(showButton ? 1 : 0)
                    .scaleEffect(showButton ? 1.0 : 0.9)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: showButton)
                }
                
                Spacer()
            }
        }
        .onAppear {
            showContent = true
            showButton = true
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    EncouragementPage(
        stage: OnboardingStage(
            id: 1,
            title: "了解你的五官",
            subtitle: "精准匹配你的美妆风格",
            emoji: "👁️",
            questions: []
        ),
        onContinue: {
            print("Continue tapped")
        }
    )
}
#endif

