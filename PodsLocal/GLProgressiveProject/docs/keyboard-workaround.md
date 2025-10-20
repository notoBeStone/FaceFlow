# SwiftUI 中键盘事件正确处理

## iOS16以下兼容
iOS16以下的 UIHostingViewController 在键盘弹起时会自动响应安全区变化，因此需要额外兼容 `GLHostingViewController`默认实现了这个功能：

```swift
public init(rootView: Content,
                isNavigationBarHidden: Bool = true,
                ignoresSafeArea: Bool = true,
                ignoresKeyboard: Bool = true) {
    self.isNavigationBarHidden = isNavigationBarHidden
    super.init(rootView: rootView)
    
    if #available(iOS 16.0, *) {
        sizingOptions = [.intrinsicContentSize]
    }
    
    if ignoresSafeArea && GLIsIPhoneX {
        disableSafeArea()
    }
    
    if ignoresKeyboard {
        disableKeyboard()
    }
}
```


**最佳实践**：使用 `GLHostingViewController`，默认 `ignoresKeyboard=true` 形参

## SwiftUI 忽略所有安全区
最佳实践：
- SwiftUI 根视图忽略所有安全区，UI内部处理额外的安全边距
- 需要避免键盘遮挡的视图使用 `ScrollView`作为根容器
- 使用 `GLUtils` 组件提供的 modifier ` func keyboardObserving(offset: CGFloat = 0.0) -> some View`

## 意外情况

SwiftUI `TabView` 控件在 iOS18以下系统有较多的兼容性问题，尤其是键盘事件，即使忽略所有安全区，仍然会自动增加额外的键盘安全区

**解决方案**：使用 HStack + Gesture实现横向分页的 TabView，以下是一个示例， 如果横向滑动体验不佳，可以适当调整滑动的阈值：

```swift
GeometryReader { geometry in
    HStack(spacing: 0) {
        TabViewItem1()
        .frame(width: geometry.size.width)
        .tag(0)
        TabViewItem2()
        .frame(width: geometry.size.width)
        .tag(1)
    }
    .offset(x: -CGFloat(selectedIndex) * geometry.size.width + translation)
    .offset(x: translation)
    .frame(width: geometry.size.width, alignment: .leading)
    .gesture(
        DragGesture()
            .updating($translation) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let offsetRatio = value.translation.width / geometry.size.width
                let predictedOffset = value.predictedEndTranslation.width / geometry.size.width
                
                if abs(predictedOffset) > 0.3 || abs(offsetRatio) > 0.2 {
                    let newIndex = selectedIndex - Int(offsetRatio.sign == .minus ? -1 : 1)
                    selectedIndex = min(max(newIndex, 0), 1) // Assuming 2 pages
                }
            }
    )
    .animation(.interactiveSpring(), value: selectedIndex)
    .animation(.interactiveSpring(), value: translation)
}
.ignoresSafeArea()
```