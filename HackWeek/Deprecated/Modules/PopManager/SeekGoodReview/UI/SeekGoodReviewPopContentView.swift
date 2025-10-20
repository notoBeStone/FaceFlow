//
//  SeekGoodReviewPopContentView.swift
//  IOSProject
//
//  Created by Martin on 2024/3/6.
//

import SwiftUI
import GLUtils
import GLMP

enum SeekGoodReviewPopActionType {
    case writeReview
    case notNow
    case close
}

struct SeekGoodReviewPopContentView: View {
    let handler: (_ type: SeekGoodReviewPopActionType)->()
    
    var body: some View {
        VStack(spacing: 0.0) {
            Image("makeBetterIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .width(150.rpx)
                .pt(24.rpx)
            Text(GLMPLanguage.feedback_popup_title)
                .fontSemiBold(20.rpx)
                .colorGWL
                .blockCenter
                .padding(.top, 32.rpx)
            
            Text(GLMPLanguage.feedback_popup_message)
                .fontMedium(16.rpx)
                .color(.g2L)
                .blockCenter
                .padding(.top, 12.rpx)
            
            Text(GLMPLanguage.feedback_popup_review)
                .fontSemiBold(16.rpx)
                .foregroundColor(Color(hex: 0xFFFFFF))
                .blockCenter
                .height(44.rpx)
                .capsuleBG(.themeColor)
                .pt(24.rpx)
                .onTapGesture {
                    self.handler(.writeReview)
                }
            
            Text(GLMPLanguage.feedback_popup_notnow)
                .fontMedium(16.rpx)
                .colorGWL
                .blockCenter
                .frame(minHeight: 36.rpx, alignment: .center)
                .padding(.top, 10.rpx)
                .onTapGesture {
                    self.handler(.notNow)
                }
        }
        .padding(.bottom, 34.rpx)
        .padding(.horizontal, 24.rpx)
        .backgroundMain
//        .overlay(alignment: .topTrailing) {
//            Image("common_close_24")
//                .size(width: 24.rpx)
//                .padding(.all, 8.rpx)
//                .controlSize(.large)
//                .onTapGesture {
//                    self.handler(.close)
//                }
//        }
    }
    
    private var top: Double {
        return 20.rpx
    }
}

#Preview {
    SeekGoodReviewPopContentView { _ in
        
    }
}
