//
//  ScanView.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import GLMP

/// Scan 页面
struct ScanView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBG
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.mainColor)
                    
                    Text(GLMPLanguage.scan_title)
                        .font(.avenirTitle2Heavy)
                        .foregroundColor(.g9L)
                    
                    Text(GLMPLanguage.scan_description)
                        .font(.avenirBodyRoman)
                        .foregroundColor(.g6L)
                }
            }
            .navigationTitle(GLMPLanguage.scan_title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ScanView()
}

