//
//  BottomSheet.swift
//  HomeDeco
//
//  Created by xie.longyan on 2024/8/15.
//

import Foundation
import SwiftUI
import ExytePopupView
import GLUtils
import GLResource

let BottomSheetBackgroundOpacity = 0.42
var BottomSheetMaxHeigth_660: CGFloat { bottomSheetMaxHeight(660) }
func bottomSheetMaxHeight(_ height: CGFloat) -> CGFloat {
    return GLScreenHeight / 812.0 * height
}

extension View {
    /// Presents a bottom sheet with the given content
    /// - Parameters:
    ///   - isPresented: Binding to control the presentation of the bottom sheet
    ///   - content: A closure returning the content to be displayed in the bottom sheet
    ///   - dismissBlock: Optional closure to be called when the bottom sheet is dismissed
    /// - Returns: A view with the bottom sheet modifier applied
    public func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        dismissBlock: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            BottomSheetViewModifier(
                isPresented: isPresented,
                popupContent: content(),
                dismissBlock: dismissBlock
            )
        )
    }
    
    /// Creates a modal bottom sheet with customizable height and content
    /// - Parameters:
    ///   - height: Optional fixed height for the bottom sheet
    ///   - isHug: Whether the bottom sheet should hug its content, default is `false`
    ///   - content: A closure returning the content to be displayed in the bottom sheet
    ///   - touchOutside: Action to be performed when tapping outside the bottom sheet
    /// - Returns: A view representing the modal bottom sheet
    public func bottomSheetModal<Content: View>(
        height: CGFloat? = nil,
        isHug: Bool = false,
        @ViewBuilder content: () -> Content,
        didTapOutside: @escaping () -> Void
    ) -> some View {
        BottomSheetModalContent(
            height: height,
            isHug: isHug,
            content: content(),
            didTapOutside: didTapOutside
        )
    }
}

struct BottomSheetViewModifier<PopUpContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let popupContent: PopUpContent
    let dismissBlock: (() -> Void)?
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    Color.black.opacity(isPresented ? BottomSheetBackgroundOpacity : 0)
                        .onTapGesture {
                            isPresented = false
                            dismissBlock?()
                        }
                    VStack {
                        Spacer()
                        
                        VStack {
                            popupContent
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.g0)
                        .cornerRadius(16.rpx, corners: [.topLeft, .topRight])
                    }
                    .offset(y: isPresented ? 0 : GLScreenHeight)
                }
                .frame(width: GLScreenWidth, height: GLScreenHeight)
                .animation(.default, value: isPresented)
            }
        
    }
}


struct BottomSheetModalContent<Content: View>: View {
    let height: CGFloat?
    var isHug: Bool = false
    let content: Content
    let didTapOutside: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: didTapOutside)
                
                ZStack {
                    content
                }
                .padding(.bottom, GLSafeBottom)
                .frame(maxWidth: .infinity)
                .if(!isHug) {
                    $0.frame(height: height ?? geometry.bottomSheetHeight)
                }
                .background(Color.g0)
                .cornerRadius(16.rpx, corners: [.topLeft, .topRight])
            }
        }
    }
}
