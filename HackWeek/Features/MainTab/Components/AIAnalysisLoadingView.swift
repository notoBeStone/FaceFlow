//
//  AIAnalysisLoadingView.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import GLMP

/// AI 分析加载页面
struct AIAnalysisLoadingView: View {
    let scanType: ScanType
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.mainBG
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // 加载动画
                ZStack {
                    Circle()
                        .stroke(Color.g3L, lineWidth: 4)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.mainColor, lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                    
                    Image(systemName: scanType == .makeup ? "sparkles" : "cube.box")
                        .font(.system(size: 40))
                        .foregroundColor(.mainColor)
                }
                
                // 加载文字
                VStack(spacing: 12) {
                    Text(GLMPLanguage.scan_analyzing)
                        .font(.avenirTitle2Heavy)
                        .foregroundColor(.g9L)
                    
                    Text(GLMPLanguage.scan_please_wait)
                        .font(.avenirBodyRoman)
                        .foregroundColor(.g6L)
                }
            }
        }
        .onAppear {
            rotation = 360
        }
    }
}

#Preview {
    AIAnalysisLoadingView(scanType: .makeup)
}

