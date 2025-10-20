[根目录](../../../CLAUDE.md) > [Incubator](../) > **ViewStack**

# ViewStack 模块

## 模块职责
ViewStack 模块是 HackWords 应用的核心导航和组件系统，提供统一的页面管理、可组合 UI 组件架构和环境变量系统。

## 入口与启动

### 主要入口文件
- **Navigator.swift**: 统一的导航管理器
- **ComposableUI.swift**: 可组合 UI 组件协议定义
- **ComposableEnv.swift**: 环境变量系统

### 启动逻辑
应用启动时，Navigator 会自动初始化并准备接受导航请求。所有页面跳转都通过 Navigator 的静态方法进行。

## 对外接口

### Navigator 核心接口
```swift
@MainActor
class Navigator {
    // 页面跳转 (推荐 - ComposablePageComponent)
    static func push<Content>(_ page: Content, animated: Bool = true, from: String? = nil)
    static func pushReplace<Content>(_ page: Content, animated: Bool = true, from: String? = nil)
    static func present<Content>(_ page: Content, animated: Bool = true, from: String? = nil)

    // 弹窗管理
    static func showPopup<Content>(_ page: Content, animated: Bool = true,
                                   targetHeight: CGFloat, completion: (() -> Void)? = nil)
    static func dismissPopup(_ animated: Bool = true, completion: (() -> Void)? = nil)

    // 传统导航 (已废弃)
    static func pop(_ animated: Bool = true)
    static func dismiss(_ animated: Bool = true, completion: (() -> Void)? = nil)
}
```

### ComposableUI 组件协议
```swift
public protocol ComposableUIComponent: View {
    associatedtype ComponentProps = Void
    init(props: ComponentProps)
    var props: ComponentProps { get }
}

public protocol ComposablePageComponent: ComposableUIComponent {
    var pageName: String { get }
    var pageTrackingParams: [String: Any]? { get }
}
```

### 环境变量系统
```swift
// 事件追踪环境变量
@Environment(\.tracking) private var tracking
// 使用方式: tracking("page_component_click", [.TRACK_KEY_TYPE: "button"])
```

## 关键依赖与配置

### 核心依赖
- **SwiftUI**: UI 框架基础
- **GLWidget**: 自定义 UI 组件库
- **GLUtils**: 工具函数库
- **GLAnalyticsUI**: 分析和追踪框架
- **GLMP**: 模板框架

### 配置信息
- **页面追踪**: 自动集成 GLMPTracking
- **类型擦除**: AnyComposableHostingController 支持任意组件类型
- **环境注入**: 自动注入追踪环境变量

## 核心组件

### Navigator 导航管理器
- **职责**: 统一的页面跳转和弹窗管理
- **特性**:
  - 支持 ComposablePageComponent 和传统 GLSwiftUIPageTrackable
  - 自动页面追踪集成
  - 弹窗高度可配置
  - 主线程安全 (@MainActor)

### ComposableUI 组件系统
- **ComposableUIComponent**: 基础组件协议，支持 Props 模式
- **ComposablePageComponent**: 页面级组件协议，支持页面追踪
- **AnyComposableHostingController**: 类型擦除的 Hosting Controller

### GLSwiftUIPageTrackable (已废弃)
传统页面追踪协议，建议迁移到 ComposablePageComponent

## 使用示例

### 创建可组合页面组件
```swift
struct MyPage: ComposablePageComponent {
    typealias ComponentProps = MyPageProps

    let props: ComponentProps
    var pageName: String { "my_page" }
    var pageTrackingParams: [String: Any]? {
        [.TRACK_KEY_FROM: "home", .TRACK_KEY_TYPE: "navigation"]
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("Action") {
                tracking("my_page_button_click", [.TRACK_KEY_TYPE: "primary"])
            }
        }
    }
}

// 使用方式
Navigator.push(MyPage(props: MyPageProps()), from: "home")
```

### 创建简单 UI 组件
```swift
struct MyButton: ComposableUIComponent {
    struct Props {
        let title: String
        let action: () -> Void
    }

    let props: Props

    var body: some View {
        Button(props.title) {
            props.action()
        }
    }
}

// 使用方式
MyButton(props: MyButtonProps(title: "Click me") {
    print("Button tapped!")
})
```

## 测试与质量

### 测试覆盖
- ✅ Navigator 导航功能测试
- ✅ ComposableUI 组件协议测试
- ✅ 页面追踪集成测试
- ✅ 环境变量系统测试

### 质量检查项
- ✅ API 设计清晰且一致
- ✅ 类型安全保证
- ✅ 错误处理完善
- ✅ 性能优化到位
- ✅ 向后兼容性良好

### 已知限制
- ComposablePageComponent 需要 props 结构体设计
- 复杂页面可能需要额外的状态管理
- 与传统 UIKit 集成需要适配器

## 常见问题 (FAQ)

### Q: ComposablePageComponent 和 GLSwiftUIPageTrackable 有什么区别？
A: ComposablePageComponent 是新的推荐方式，支持 Props 模式和更好的类型安全。GLSwiftUIPageTrackable 是传统方式，已标记为废弃。

### Q: 如何在组件中使用环境变量？
A: 使用 `@Environment(\.tracking)` 获取追踪环境变量，其他环境变量需要自行定义。

### Q: 页面追踪参数有什么限制？
A: 必须使用预定义的 TrackKey 常量，遵循 3 段式命名规范：`page_component_action`。

### Q: 如何处理复杂的状态管理？
A: 对于页面级组件，建议使用 ComposableViewModel 基类，它提供了常用的状态管理方法。

### Q: 弹窗的高度如何配置？
A: 使用 `targetHeight` 参数，默认为 `ScreenHeight - StatusBarHeight`。

## 相关文件清单

### 核心文件
- `Navigator.swift` - 导航管理器
- `ComposableUI.swift` - 可组合UI协议
- `ComposableEnv.swift` - 环境变量系统

### 协议定义
- `ComposableUIComponent` - 基础组件协议
- `ComposablePageComponent` - 页面组件协议
- `GLSwiftUIPageTrackable` - 传统页面追踪协议 (已废弃)

### 实现类
- `AnyComposableHostingController` - 类型擦除的 Hosting Controller
- `GLCommonHostingController` - 传统 Hosting Controller
- `GLCommonHostingPopup` - 弹窗 Hosting Controller

### 依赖关系
- **依赖模块**: GLWidget, GLUtils, GLAnalyticsUI, GLMP
- **被依赖模块**: Features/* (所有功能模块)
- **外部依赖**: SwiftUI, UIKit

## 变更记录 (Changelog)

### 2025-10-16
- 创建 ViewStack 模块详细文档
- 分析导航系统和组件架构
- 确定测试覆盖和质量状态

### 历史变更
- 引入 ComposableUI 协议系统
- 添加环境变量支持
- 废弃传统 GLSwiftUIPageTrackable API
- 优化性能和类型安全