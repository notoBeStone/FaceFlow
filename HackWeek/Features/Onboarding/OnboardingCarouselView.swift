//
//  OnboardingCarouselView.swift
//  HackWords
//
//  Created by Claude on 2025/10/24.
//

import SwiftUI

/// Onboarding 轮播图页面
struct OnboardingCarouselView: View {
    let onComplete: () -> Void
    
    @State private var currentPage: Int = 0
    @State private var timer: Timer?
    
    private let totalPages = 3
    private let autoScrollInterval: TimeInterval = 2.0
    
    // 轮播数据
    private let carouselData: [(imageName: String, title: String)] = [
        ("onboarding_2", GLMPLanguage.onboarding_carousel_title1),
        ("onboarding_3", GLMPLanguage.onboarding_carousel_title2),
        ("onboarding_4", GLMPLanguage.onboarding_carousel_title3)
    ]
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 轮播图片 (只有图片) - 左右上贴紧屏幕
                TabView(selection: $currentPage) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Image(carouselData[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .aspectRatio(750.0 / 1623.0, contentMode: .fit)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(true) // 禁用手势滑动
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // 文案
                Text(carouselData[currentPage].title)
                    .font(Font.custom("Avenir", size: 24))
                    .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                    .frame(width: 273, alignment: .topLeading)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                    .frame(height: 48)
                
                // 自定义页面指示器
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 7, height: 7)
                            .background(index == currentPage ? .white.opacity(0.8) : .white.opacity(0.25))
                            .cornerRadius(7)
                    }
                }
                .padding(.bottom, 38)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 右上角 Skip 按钮 - 在 ZStack 顶层
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        stopTimer()
                        onComplete()
                    }) {
                        Text(GLMPLanguage.onboarding_carousel_skip)
                            .font(.avenirBodyMedium)
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 16)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Auto Scroll
    
    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                if currentPage < totalPages - 1 {
                    // 未到最后一页，继续滚动
                    currentPage += 1
                } else {
                    // 已到最后一页，等待后自动跳转
                    stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + autoScrollInterval) {
                        onComplete()
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    OnboardingCarouselView {
        debugPrint("Carousel completed")
    }
}
#endif

