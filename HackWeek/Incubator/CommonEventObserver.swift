import Combine

/// ViewController生命周期事件观察者, 通过 @EnvironmentObject 注入到 SwiftUI 视图中
/// 使用方法:
/// ```swift
/// @EnvironmentObject var viewControllerEventObserver: ViewControllerEventObserver
///
/// var body: some View {
///     Text("Hello, World!")
///     .onReceive(viewControllerEventObserver.viewWillAppearEvent) {
///         print("viewWillAppear")
///     }
/// }
/// ```
class ViewControllerEventObserver: ObservableObject {
    let viewDidLoadEvent = PassthroughSubject<Void, Never>()
    let viewWillAppearEvent = PassthroughSubject<Void, Never>()
    let viewDidAppearEvent = PassthroughSubject<Void, Never>()
    let viewWillDisappearEvent = PassthroughSubject<Void, Never>()
    let viewDidDisappearEvent = PassthroughSubject<Void, Never>()
}

/// 转化页生命周期事件观察者, 继承自 ViewControllerEventObserver, 通过 @EnvironmentObject 注入到 SwiftUI 视图中
/// 使用方法:
/// ```swift
/// @EnvironmentObject var conversionEventObserver: ConversionEventObserver
///
/// var body: some View {
///     Text("Hello, World!")
///     .onReceive(conversionEventObserver.updateUIEvent) {
///         print("updateUI")
///     }
/// }
/// ```
class ConversionEventObserver: ViewControllerEventObserver {
    let updateUIEvent = PassthroughSubject<Void, Never>()
}
