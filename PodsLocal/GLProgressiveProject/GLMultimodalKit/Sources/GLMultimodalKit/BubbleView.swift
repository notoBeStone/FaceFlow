//
//  SwiftUIView.swift
//  GLMultimodalKit
//
//  Created by stephenwzl on 2025/2/12.
//

import SwiftUI

public struct BubbleView: View {
    let content: AnyView
    let alignment: Alignment
    
    /// 创建一个对话气泡视图
    ///   - Parameters:
    ///   - alignment: 对话气泡中内容的排列方式
    ///   - content: 对话气泡中内容，可以是任何 SwiftUI 视图
    public init(alignment: Alignment = .leading, content: @escaping () -> some View) {
        self.content = AnyView(content())
        self.alignment = alignment
    }
    
//    public static func loadingView(alignment: Alignment = .leading, foregroundColor: Color = Color.gray) -> Self {
//        return BubbleView(alignment: .leading) {
//            BubbleLoadingView(color: foregroundColor)
//        }
//    }
    
    public var body: some View {
        HStack(spacing: 0) {
            if alignment == .trailing {
                Spacer(minLength: 0)
            }
            content
            if alignment == .leading {
                Spacer(minLength: 0)
            }
        }
    }
}

extension BubbleView {
    /// 将视图裁剪为气泡形状
    /// - Parameters:
    ///   - radius: 气泡的圆角半径
    ///   - corners: 气泡的圆角位置，默认是左气泡的圆角位置，如果是右气泡，则需要传入 .rightBubbleCorners
    public func bubbleClipped(_ radius: CGFloat, corners: UIRectCorner = .leftBubbleCorners) -> some View {
        content.modifier(BubbleClipModifier(radius: radius, corners: corners))
    }
}

fileprivate struct BubbleClipModifier: ViewModifier {
    let radius: CGFloat
    let corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content.clipShape(BubbleShape(radius: radius, corners: corners))
    }
}

extension UIRectCorner {
    public static let leftBubbleCorners: UIRectCorner = [.topRight, .bottomLeft, .bottomRight]
    public static let rightBubbleCorners: UIRectCorner = [.topLeft, .bottomLeft, .bottomRight]
}

public struct BubbleShape: Shape {
    public var radius: CGFloat = 0
    public var corners: UIRectCorner = .allCorners
    
    public init(radius: CGFloat = 0, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public struct BubbleLoadingView: View {
    let color: Color
    let spacing: CGFloat
    let size: CGFloat
    @State private var loadingIndex = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    /// 创建一个气泡加载视图
    /// - Parameters:
    ///   - color: 加载视图的颜色
    ///   - spacing: 加载圆点之间的间距，默认是4
    ///   - size: 加载圆点的大小，默认是5
    public init(color: Color = .gray, spacing: CGFloat = 4, size: CGFloat = 5) {
        self.color = color
        self.spacing = spacing
        self.size = size
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color.opacity(loadingIndex == 0 ? 1 : 0.3))
                .frame(width: 5, height: 5)
            Circle()
                .fill(color.opacity(loadingIndex == 1 ? 1 : 0.3))
                .frame(width: 5, height: 5)
            Circle()
                .fill(color.opacity(loadingIndex == 2 ? 1 : 0.3))
                .frame(width: 5, height: 5)
        }
        .onReceive(timer) { _ in
            switch loadingIndex {
            case 0:
                loadingIndex = 1
            case 1:
                loadingIndex = 2
            case 2:
                loadingIndex = 0
            default:
                loadingIndex = 0
            }
        }
    }
}
