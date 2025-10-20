# Navigator 路由系统使用指南

## 概述

Navigator 是 HackWeek 模板的核心路由系统，提供统一的页面导航管理。该系统基于企业级架构设计，支持多种导航方式，自动集成埋点追踪，并提供类型安全保障。

## 核心特性

- ✅ **多种导航方式**: Push、Present、Popup、Replace
- ✅ **自动埋点追踪**: 无需手动添加追踪代码
- ✅ **类型安全**: 基于 ComposablePageComponent 的类型检查
- ✅ **主线程安全**: 所有操作都在主线程执行
- ✅ **错误处理**: 完善的错误处理机制
- ✅ **动画支持**: 可配置的导航动画

## 快速开始

### 基本使用

```swift
// 1. 创建可组合页面组件
struct MyPage: ComposablePageComponent {
    struct Props {
        let title: String
        let message: String
    }

    let props: Props
    var pageName: String { "my_page" }
    var pageTrackingParams: [String: Any]? {
        [.TRACK_KEY_TYPE: "demo"]
    }

    var body: some View {
        VStack {
            Text(props.title)
            Text(props.message)
        }
    }
}

// 2. 使用导航
Navigator.push(
    MyPage(props: MyPageProps(title: "Hello", message: "World")),
    from: "home"
)
```

### 传统视图导航

```swift
// 对于传统 SwiftUI View，也可以直接导航
Navigator.push(
    Text("Hello World"),
    from: "current_page"
)
```

## API 接口详解

### 1. Push 导航（页面栈）

#### 基本语法
```swift
static func push<Content>(
    _ view: Content,
    animated: Bool = true,
    from: String? = nil
) where Content: View
```

#### 使用示例
```swift
// 基本使用
Navigator.push(DetailView(), from: "list_page")

// 带动画控制
Navigator.push(SettingsPage(), animated: true, from: "profile")

// 可组合页面组件
Navigator.push(
    UserProfilePage(props: UserProfileProps(userId: "123")),
    from: "user_list"
)
```

#### 应用场景
- 从列表页跳转到详情页
- 导航到设置页面
- 层级式页面导航

### 2. Present 导航（模态展示）

#### 基本语法
```swift
static func present<Content>(
    _ view: Content,
    animated: Bool = true,
    from: String? = nil
) where Content: View
```

#### 使用示例
```swift
// 基本模态展示
Navigator.present(ComposeView(), from: "inbox")

// 编辑页面模态展示
Navigator.present(
    EditProfileView(props: EditProfileProps(user: currentUser)),
    from: "profile_page"
)

// 系统页面展示
Navigator.present(imagePickerController, animated: true)
```

#### 应用场景
- 显示编辑页面
- 表单输入页面
- 临时功能页面
- 系统组件展示

### 3. Popup 导航（底部弹窗）

#### 基本语法
```swift
static func showPopup<Content>(
    _ page: Content,
    animated: Bool = true,
    targetHeight: CGFloat,
    completion: (() -> Void)? = nil
) where Content: View

static func dismissPopup(
    _ animated: Bool = true,
    completion: (() -> Void)? = nil
)
```

#### 使用示例
```swift
// 显示底部弹窗
Navigator.showPopup(
    ShareView(props: ShareProps(content: shareContent)),
    targetHeight: ScreenHeight * 0.7,
    completion: {
        print("弹窗显示完成")
    }
)

// 关闭弹窗
Navigator.dismissPopup {
    print("弹窗关闭完成")
}
```

#### 应用场景
- 分享功能弹窗
- 选择器界面
- 确认对话框
- 底部操作菜单

### 4. Replace 导航（页面替换）

#### 基本语法
```swift
static func pushReplace<Content>(
    _ view: Content,
    animated: Bool = true,
    from: String? = nil
) where Content: View
```

#### 使用示例
```swift
// 替换当前页面
Navigator.pushReplace(MainAppView(), from: "onboarding_complete")

// 登录后替换页面
Navigator.pushReplace(
    DashboardView(props: DashboardProps(user: loggedInUser)),
    from: "login_page"
)
```

#### 应用场景
- 登录/注册完成后的页面跳转
- Onboarding 完成后进入主应用
- 重置应用流程状态

### 5. 传统导航方法

```swift
// 返回上一页
Navigator.pop()

// 返回到根视图
Navigator.popAll()

// 关闭模态页面
Navigator.dismiss {
    print("页面关闭完成")
}

// 重置导航栈
Navigator.reset(HomeView())
```

## 可组合页面组件

### ComposablePageComponent 协议

```swift
public protocol ComposablePageComponent: ComposableUIComponent {
    var pageName: String { get }
    var pageTrackingParams: [String: Any]? { get }
}
```

### 创建页面组件

```swift
struct UserDetailPage: ComposablePageComponent {
    struct Props {
        let userId: String
        let showEditButton: Bool
    }

    let props: Props

    // 页面名称（用于埋点）
    var pageName: String { "user_detail" }

    // 页面追踪参数
    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_USER_ID: props.userId,
            .TRACK_KEY_TYPE: props.showEditButton ? "editable" : "readonly"
        ]
    }

    var body: some View {
        VStack {
            // 用户信息展示
            UserInfoView(userId: props.userId)

            if props.showEditButton {
                Button("编辑") {
                    // 编辑操作
                }
            }
        }
    }
}
```

### Props 设计最佳实践

```swift
// ✅ 好的 Props 设计
struct ProductDetailProps {
    let productId: String              // 必需参数
    let isEditable: Bool = false       // 可选参数，有默认值
    let onPurchase: ((String) -> Void)? // 可选回调

    // 内部验证
    var isValid: Bool {
        !productId.isEmpty
    }
}

// ❌ 避免的 Props 设计
struct BadProps {
    let view: AnyView                   // 不要传递 View
    let navigationController: UINavigationController // 不要传递 UIKit 对象
    let data: [String: Any]           // 不要使用字典，使用具体类型
}
```

## 埋点追踪系统

### 自动追踪

Navigator 自动为所有导航操作添加埋点追踪：

```swift
// 这行代码会自动生成以下埋点事件：
Navigator.push(DetailView(), from: "list_page")

// 自动生成的事件：
// - event: page_navigation_push
// - params: {
//     from: "list_page",
//     to: "detail_view",
//     page_name: "detail_view",
//     timestamp: 1234567890
// }
```

### 自定义页面追踪

```swift
struct CustomPage: ComposablePageComponent {
    var pageName: String { "custom_page" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_TYPE: "premium_feature",
            .TRACK_KEY_CATEGORY: "education",
            .TRACK_KEY_LEVEL: "advanced"
        ]
    }
}
```

### 手动埋点

在页面内部添加自定义埋点：

```swift
struct MyPage: View {
    @Environment(\.tracking) private var tracking

    var body: some View {
        VStack {
            Button("重要操作") {
                // 自定义埋点事件
                tracking("important_action_click", [
                    .TRACK_KEY_TYPE: "primary",
                    .TRACK_KEY_CATEGORY: "user_interaction"
                ])
            }
        }
    }
}
```

## 实际应用场景

### 1. Onboarding 流程

```swift
struct OnboardingFlow {
    func startOnboarding() {
        // 第一步：欢迎页面
        Navigator.push(
            OnboardingWelcomePage(),
            from: "app_launch"
        )
    }

    func nextStep(from currentStep: String) {
        switch currentStep {
        case "welcome":
            Navigator.push(
                OnboardingAgePage(),
                from: "onboarding_welcome"
            )
        case "age":
            Navigator.push(
                OnboardingLanguagePage(),
                from: "onboarding_age"
            )
        case "language":
            // 完成后替换到主应用
            Navigator.pushReplace(
                MainAppView(),
                from: "onboarding_complete"
            )
        default:
            break
        }
    }
}
```

### 2. 主应用导航

```swift
struct MainNavigationView: View {
    var body: some View {
        TabView {
            // 首页
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("首页")
                }

            // 搜索页面
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("搜索")
                }

            // 个人中心
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("我的")
                }
        }
    }
}

// 页面内导航示例
struct HomeView: View {
    var body: some View {
        VStack {
            Button("查看详情") {
                Navigator.push(
                    DetailView(props: DetailProps(id: "123")),
                    from: "home"
                )
            }

            Button("设置") {
                Navigator.present(
                    SettingsView(),
                    from: "home"
                )
            }

            Button("分享") {
                Navigator.showPopup(
                    ShareView(props: ShareProps(content: shareContent)),
                    targetHeight: 300
                )
            }
        }
    }
}
```

### 3. 模态表单

```swift
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                // 表单字段
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        Navigator.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                        Navigator.dismiss()
                    }
                }
            }
        }
    }
}

// 使用示例
Navigator.present(EditProfileView(), from: "profile")
```

### 4. 复杂页面流程

```swift
struct ComplexFlow {
    func startPurchaseFlow(productId: String) {
        // 第一步：产品详情
        Navigator.push(
            ProductDetailPage(props: ProductDetailProps(productId: productId)),
            from: "product_list"
        )
    }

    func selectPlan(productId: String) {
        // 第二步：选择订阅计划
        Navigator.present(
            SubscriptionPlanPage(props: SubscriptionProps(productId: productId)),
            from: "product_detail"
        )
    }

    func paymentProcess(skuId: String) {
        // 第三步：支付处理
        Navigator.present(
            PaymentPage(props: PaymentProps(skuId: skuId)),
            from: "subscription_plan"
        )
    }

    func purchaseComplete() {
        // 完成后关闭所有模态页面
        Navigator.dismiss {
            // 显示成功提示
            Navigator.showPopup(
                PurchaseSuccessView(),
                targetHeight: 200
            )
        }
    }
}
```

## 错误处理

### 常见错误类型

```swift
// 页面不存在
Navigator.push(NonExistentPage(), from: "current") // 会触发错误处理

// 参数错误
Navigator.push(InvalidPage(props: invalidProps), from: "current")

// 导航栈异常
Navigator.pop() // 当没有上一页时
```

### 错误处理策略

```swift
// 在 Navigator 内部实现的错误处理
class Navigator {
    private func handleNavigationError(_ error: Error, from: String?) {
        // 1. 记录错误日志
        print("Navigation error: \(error.localizedDescription)")

        // 2. 发送错误埋点
        tracking("navigation_error", [
            .TRACK_KEY_ERROR: error.localizedDescription,
            .TRACK_KEY_SOURCE: from ?? "unknown"
        ])

        // 3. 显示用户友好的错误提示
        DispatchQueue.main.async {
            // 显示错误提示
        }
    }
}
```

### 自定义错误处理

```swift
extension Navigator {
    static func safePush<Content>(_ view: Content, from: String?) where Content: View {
        do {
            // 验证导航条件
            try validateNavigationConditions()

            // 执行导航
            push(view, from: from)
        } catch {
            // 处理错误
            handleNavigationError(error, from: from)
        }
    }
}
```

## 性能优化

### 1. 避免过度导航

```swift
// ❌ 避免的做法
func badNavigation() {
    for i in 0..<100 {
        Navigator.push(DetailView(id: i), from: "list")
    }
}

// ✅ 推荐的做法
func goodNavigation() {
    // 使用分页加载
    Navigator.push(
        PaginatedDetailView(page: 1),
        from: "list"
    )
}
```

### 2. 合理使用动画

```swift
// 对于频繁的导航，可以关闭动画
Navigator.push(QuickView(), animated: false, from: "current")

// 对于重要页面，保持动画
Navigator.push(ImportantView(), animated: true, from: "current")
```

### 3. 内存管理

```swift
struct MyPage: View {
    // 使用 @StateObject 管理复杂对象
    @StateObject private var viewModel = MyViewModel()

    // 避免循环引用
    var body: some View {
        MyContentView(viewModel: viewModel)
            .onDisappear {
                // 清理资源
                viewModel.cleanup()
            }
    }
}
```

## 测试策略

### 单元测试

```swift
import XCTest
@testable import YourApp

class NavigatorTests: XCTestCase {
    func testPushNavigation() {
        // 创建测试视图
        let testView = Text("Test View")

        // 执行导航
        Navigator.push(testView, from: "test")

        // 验证导航结果
        // （需要根据具体实现编写验证逻辑）
    }

    func testPageTracking() {
        // 创建带有追踪参数的页面
        let testPage = TrackedPage()

        // 执行导航
        Navigator.push(testPage, from: "test")

        // 验证埋点事件
        // （需要配合埋点测试工具）
    }
}
```

### UI 测试

```swift
import XCTest

class NavigationUITests: XCTestCase {
    func testNavigationFlow() {
        let app = XCUIApplication()
        app.launch()

        // 测试导航按钮
        let navigationButton = app.buttons["Go to Detail"]
        XCTAssertTrue(navigationButton.exists)
        navigationButton.tap()

        // 验证页面跳转
        let detailTitle = app.staticTexts["Detail Page"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 2))
    }
}
```

## 最佳实践总结

### 1. 页面设计
- 保持页面的单一职责
- 使用 Props 模式传递参数
- 实现适当的协议和类型定义

### 2. 导航使用
- 明确指定导航来源参数
- 选择合适的导航方式
- 注意内存管理和性能

### 3. 埋点追踪
- 利用自动埋点功能
- 为重要页面添加自定义追踪参数
- 遵循统一的命名规范

### 4. 错误处理
- 实现优雅的错误处理
- 提供用户友好的错误提示
- 记录详细的错误日志

---

*Navigator 路由系统为 HackWeek 提供了统一、安全、高性能的页面导航解决方案，是企业级 iOS 应用的重要基础设施。*