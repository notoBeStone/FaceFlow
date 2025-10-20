//
//  NormalBottomSheetView.swift
//  AINote
//
//  Created by user on 2024/9/5.
//

import SwiftUI
import GLResource
import GLUtils
import GLWidget
import ExytePopupView

#if DEBUG
struct NormalBottomSheetView_Preview: PreviewProvider {
    @State static var show: Bool = false
    static var previews: some View {
        VStack {
            Rectangle()
                .foregroundColor(.blue)
                .frame(width: 100.rpx, height: 100.rpx)
                .onTapGesture {
                    show = true
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .normalBottomSheet(isPresented: $show, title: "这是一个文案") {
            Text(
                "Spray the soapy water solution directly on the infested plant, thoroughly coating all surfaces of the leaves, stems, and undersides of leaves."
            )
            .textStyle(.footnoteRegular)
            .foregroundColor(.g8)
        }
    }
}
#endif


extension View {
    public func normalBottomSheet<Content>(isPresented: Binding<Bool>, title: String? = nil, @ViewBuilder content: @escaping () -> Content, closeAction: (() -> Void)? = nil) -> some View where Content: View {
        modifier(NormalBottomSheetViewModifier(isPresented: isPresented, title: title, content: content, closeAction: closeAction))
    }
}

// 创建一个NormalBottomSheetViewModifier类
fileprivate struct NormalBottomSheetViewModifier<SheetContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    
    private var title: String?

    private let contentViewBuilder: () -> SheetContent
    
    private var closeAction: (() -> Void)?
    
    public init(isPresented: Binding<Bool>, title: String?, @ViewBuilder content: @escaping () -> SheetContent, closeAction: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.title = title
        self.contentViewBuilder = content
        self.closeAction = closeAction
    }
    
    func body(content: Content) -> some View {
        content
            .popup(isPresented: $isPresented) {
                NormalBottomSheetView(isPresented: $isPresented, title: title, content: contentViewBuilder, closeAction: closeAction)
            } customize: { param in
                param
                    .position(.bottom)
                    .disappearTo(.bottomSlide)
                    .closeOnTap(false)
                    .closeOnTapOutside(false) //用于控制点击外部是否关闭弹窗
                    .isOpaque(true) //用于控制是否是present形式弹出，可用于遮盖底部tabbar
                    .backgroundColor(.black.opacity(0.4))
                    .useKeyboardSafeArea(true)

            }
    }
}


fileprivate struct NormalBottomSheetView<Content>: View where Content: View {
    
    @Binding var isPresented: Bool
    
    private var title: String?

    private let content: Content
    
    private var closeAction: (() -> Void)?
    
    public init(isPresented: Binding<Bool>, title: String?, @ViewBuilder content: () -> Content, closeAction: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
        self.closeAction = closeAction
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0.rpx) {
                HStack {
                    Text(title ?? "")
                        .textStyle(.bodyBold)
                        .foregroundColor(.g9)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                }
                .padding(.horizontal, 16.rpx)
                .padding(.vertical, 19.rpx)
                
                content
            }
            .background(Color.gW)
            .cornerRadius(16.rpx, corners: [.topLeft, .topRight])
            .clipped()
            
            //close Button
            
            Rectangle()
                .foregroundColor(.g0N)
                .frame(width: 32.rpx, height: 32.rpx)
                .background(
                    Image("icon_close_outlined_heavy")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.g5N)
                        .frame(width: 20.rpx, height: 20.rpx)
                )
                .clipShape(style: .circle)
                .padding(.top, 16.rpx)
                .padding(.trailing, 16.rpx)
                .controlSize(.large)
                .onTapGesture {
                    if let closeAction = closeAction {
                        closeAction()
                    } else {
                        isPresented = false
                    }
                }
        }
        .ignoresSafeArea()
    }
}
