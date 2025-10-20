//
//  SelectableBottomSheet.swift
//  AINote
//
//  Created by user on 2024/8/9.
//

import SwiftUI
import GLUtils

struct SelectableBottomSheet<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let title: String
    
    private let data: Data
    private let content: (Int, Data.Element) -> Content
    
    let cancelAction: (() -> Void)
    let doneAction: (() -> Void)
    
    init(title: String, data: Data, @ViewBuilder content: @escaping (Int, Data.Element) -> Content, cancelAction: @escaping () -> Void, doneAction: @escaping () -> Void) {
        self.title = title
        self.data = data
        self.content = content
        self.cancelAction = cancelAction
        self.doneAction = doneAction
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            //Header
            HStack(spacing: 0) {
                
                Text(GLMPLanguage.text_cancel)
                    .textStyle(.footnoteMedium)
                    .foregroundColor(.p5)
                    .controlSize(.large)
                    .onTapGesture {
                        cancelAction()
                    }
                
                Spacer()
                
                Text(title)
                    .textStyle(.footnoteMedium)
                    .foregroundColor(.g9)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Text(GLMPLanguage.text_done)
                    .textStyle(.footnoteMedium)
                    .foregroundColor(.p5)
                    .controlSize(.large)
                    .onTapGesture {
                        doneAction()
                    }
            }
            .padding(.horizontal, 16.rpx)
            .frame(height: GLScreen.navigationBarHeight)
            .frame(maxWidth: .infinity)
            .background(
                GLLineView(color: Color.g2N, lineWidth: 0.5),
                alignment: .bottom
            )
            
            VStack(spacing: 0) {
                LazyVGrid(columns: [GridItem(.flexible())]) {
                    ForEach(Array(data.enumerated()), id: \.element) { index, element in
                        content(index, element)
                    }
                }
            }
            .padding(.vertical, 20.rpx)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, GLScreen.safeBottom)
        .background(Color.g0)
        .cornerRadius(8.rpx, corners: [.topLeft, .topRight])
    }
}


struct SelectableItemView: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 0.rpx) {
            Text(text)
                .textStyle(isSelected ? .footnoteBold : .footnoteRegular)
                .foregroundColor(.g9)
            
            Spacer()
            
            if isSelected {
                Image("icon_success_outlined_heavy")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.p5)
                    .frame(width: 20.rpx, height: 20.rpx)
            }
        }
        .padding(.vertical, 12.rpx)
        .padding(.horizontal, 16.rpx)
        .contentShape(Rectangle())
    }
}
