# HackWeek Incubator 转化页实现说明

## 概述

本文档详细说明了基于 HackWeek 模板项目的 Paywall（付费墙）转化页实现方案。该方案在保持与现有系统兼容的同时，采用 SwiftUI 实现现代化的 UI 界面。

## 架构设计

### 实现考虑因素

1. **兼容既有的转化页弹起方式**：支持 AB 通道版本，通过 Objective-C class 动态弹起
2. **兼容既有的 GLOCVipBaseViewController API**：完整保留购买、loading 等核心功能接口
3. **使用 SwiftUI 实现 UI**：简化 UI 开发，提高开发效率

### 核心组件

#### 1. ConversionMisc.swift (Incubator/ConversionMisc.swift)

**PaywallNotifier** - 付费墙通知管理器
- `showVip(from:animationType:)` - 显示付费墙的核心方法
- 支持两种动画类型：`.present`（模态）和 `.aboveCurrent`（添加到当前视图）
- 集成 AB 测试和用户历史记录

**BasicConversionController** - 转化页基础控制器
- 继承自 `GLOCVipBaseViewController`，保持完全兼容性
- 实现 `PaywallNotifierDelegate` 协议处理付费墙交互
- 集成 SwiftUI 视图到 UIKit 架构中

**PaywallNotifierDelegate** - 付费墙代理协议
```swift
protocol PaywallNotifierDelegate: NSObjectProtocol {
    func closeAction()
    func startAction(_ skuId: String, trialable: Bool)
    func termsOfUseAction()
    func privacyPolicyAction()
    func subscriptionAction()
    func restoreAction()
    func setCurrentSkus(skus: [String])
    var trialReminderEnabled: Bool { get set }
    func changeTo(on: Bool, completion: @escaping (_ granted: Bool) -> Void)
}
```

#### 2. 转化页视图组件 (Features/VipConversion/)

**VipConversionViewModel** - 转化页视图模型
- 管理 SKU 数据和状态
- 处理购买逻辑和用户交互
- 支持多种 AB 实验通道（memoType）对应不同的实验版本
- 注意：memo 是 AB实验的通道，用于区分不同的实验版本，容易与 memory 混淆

**SwiftUI 转化页** - 各种转化页视图实现
- `TrialableVipConversionPage` - 支持试用的转化页（默认）
- `HistoryVipConversionView` - 历史用户转化页

## 实现优缺点分析

### 优点

1. **兼容性强**：完整保留了原有的 `GLOCVipBaseViewController` API，无需修改现有调用代码
2. **架构清晰**：通过 Incubator 暴露接口，Deprecated 隐藏实现细节，符合项目架构规范
3. **开发效率高**：使用 SwiftUI 实现 UI，代码更简洁，维护成本更低
4. **AB 测试支持**：通过 AB 实验通道机制支持多种转化页版本的 AB 测试
5. **类型安全**：SwiftUI 提供编译时类型检查，减少运行时错误
6. **响应式设计**：自动适配 iPhone 和 iPad，支持不同屏幕尺寸

### 不足与改进建议

1. **代码重复**：不同转化页视图存在重复的 UI 代码
   - **建议**：抽取公共组件，创建可复用的 SwiftUI 组件库

2. **硬编码问题**：SKU 列表和 UI 常量直接写在代码中
   - **建议**：将配置信息移至 JSON 文件或远程配置

3. **国际化支持**：文案硬编码，未完全支持多语言
   - **建议**：使用本地化字符串，支持动态语言切换

4. **错误处理**：异步操作的错误处理机制可以更完善
   - **建议**：增加统一的错误处理和用户提示机制

5. **测试覆盖**：缺少自动化测试，特别是 UI 组件测试
   - **建议**：增加单元测试和 UI 测试覆盖率

## 使用方式

### 1. 显示付费墙

```swift
// 基础用法
PaywallNotifier.shared.showVip()

// 指定来源和动画类型
PaywallNotifier.shared.showVip(from: "home_page", animationType: .aboveCurrent)
```

### 2. 创建新的转化页

#### 步骤 1：创建 SwiftUI 视图
```swift
struct NewConversionPage: View {
    @StateObject private var viewModel = VipConversionViewModel(memoType: "new_memo")
    @EnvironmentObject var conversionObserver: ConversionEventObserver

    var body: some View {
        // 实现 UI 界面
    }
}
// 注意：memo 是 AB实验的通道，用于区分不同的实验版本，容易与 memory 混淆
```

#### 步骤 2：创建对应的 ViewController
```swift
@objc class VipNewMemoAViewController: BasicConversionController {
    override open func setupMainUI() {
        self.addSwiftUI(viewController: .init(rootView: NewConversionPage().environmentObject(conversionObserver))) { make in
            make.edges.equalToSuperview()
        }
    }
}
```

#### 步骤 3：配置 SKU 列表
在 `VipConversionViewModel` 中添加新的 AB 实验通道和对应的 SKU 列表。

### SKU 配置管理

#### 1. SKU 配置文件位置

**AppConfigMisc.swift** (`PodsLocal/AppConfig/AppConfig/AppConfigMisc.swift`)
- 包含所有 SKU 的具体配置信息
- 定义了 `AppEvoConfig.skuConfig` 静态属性
- 每个 SKU 包含：skuId、计费周期、试用天数、分类、adjustToken、等级

**SkuMisc.swift** (`PodsLocal/AppConfig/AppConfig/SkuMisc.swift`)
- 定义了 `AppSkuConfigModel` 结构体
- 提供 SKU 配置的数据模型声明
- 包含将配置转换为 `SkuSubscriptionModel` 的方法

#### 2. SKU 配置结构详解

```swift
struct AppSkuConfigModel {
    let skuId: String          // App Store Connect 中填写的 SKU ID
    let period: SkuPeriod      // 计费周期（周包/年包等）
    let trialDays: Int         // 试用天数，默认为 0（无试用）
    let category: SkuCategory  // SKU 分类（如免费试用、无试用等）
    let adjustToken: String?   // 调整 token（可选）
    let skuLevel: SkuLevel     // SKU 等级，默认为 gold
}
```

#### 3. 常见计费周期和分类

**计费周期 (SkuPeriod)**
- `.weekly` - 周包
- `.yearly` - 年包
- `.monthly` - 月包

**SKU 分类 (SkuCategory)**
- `.freeTrail` - 免费试用
- `.none` - 无试用

**SKU 等级 (SkuLevel)**
- `.gold` - 黄金会员（默认）

#### 4. 添加新 SKU 配置

在 `AppConfigMisc.swift` 的 `skuConfig` 数组中添加新的 SKU：

```swift
// 示例：添加一个新的月包配置
.init(skuId: "HackWords_sub_month",
      period: .monthly,
      trialDays: 7,
      category: .freeTrail,
      adjustToken: nil,
      skuLevel: .gold),
```

#### 5. 在转化页中使用 SKU

转化页通过 `VipConversionViewModel` 的 `setCurrentSkus(skus:)` 方法设置当前可用的 SKU 列表：

```swift
// 设置可用的 SKU 列表
viewModel.setCurrentSkus(skus: ["HackWords_sub_year", "HackWords_sub_week_3dt"])
```

### 3. 转化页事件处理

转化页通过 `PaywallNotifierDelegate` 处理各种用户交互：

- **购买流程**：`startAction(_:trialable:)` 处理购买逻辑
- **页面关闭**：`closeAction()` 处理关闭操作
- **法律文档**：`termsOfUseAction()`、`privacyPolicyAction()`、`subscriptionAction()` 打开相应文档
- **恢复购买**：`restoreAction()` 处理恢复购买逻辑
- **试用提醒**：`changeTo(on:completion:)` 管理试用提醒设置

### 4. AB 测试配置

通过 `memoType` 参数支持不同 AB 实验通道的转化页：

```swift
// 在 PaywallNotifier.shared.showVip() 中
let memo = GL().ABTesting_ValueForKey("conversion_page", activate: false) ?? ConversionConfig.defaultMemo
// 注意：memo 是 AB实验的通道，用于区分不同的实验版本，容易与 memory 混淆
```

系统会根据 AB 测试结果动态选择对应的转化页实现。

## 最佳实践

1. **组件复用**：将常用的 UI 元素（如价格显示、特性列表）抽取为独立组件
2. **配置外化**：将文案、SKU 配置等信息外置到配置文件中
3. **状态管理**：合理使用 `@StateObject`、`@EnvironmentObject` 进行状态管理
4. **性能优化**：注意 SwiftUI 视图的性能，避免不必要的重绘
5. **错误处理**：完善异步操作的错误处理和用户反馈机制

## Composable UI 组件开发规范

### 1. 核心协议

#### ComposableUIComponent 协议
```swift
public protocol ComposableUIComponent: View {
    associatedtype ComponentProps = Void
    init(props: ComponentProps)
    var props: ComponentProps { get }
}
```

#### ComposablePageComponent 协议（页面级组件）
```swift
public protocol ComposablePageComponent: ComposableUIComponent {
    var pageName: String { get }
    var pageTrackingParams: [String: Any]? { get }
}
```

#### ComposableViewModel 基类
页面组件推荐使用 ViewModel 模式，继承自 `ComposableViewModel`：
```swift
class SomePageViewModel: ComposableViewModel {
    // 使用父类提供的三个核心方法：
    // - userInfo() -> UserInfo  // 获取用户信息（VIP状态等）
    // - showVipPage(from: String, animationType: VipAnimationType = .present)  // 显示VIP页面
    // - tracking(_ eventName: String, _ params: [String: Any]? = nil)  // 事件追踪
}
```

### 2. 环境变量系统

#### 事件追踪
```swift
@Environment(\.tracking) private var tracking
// 使用：tracking("home_button_click", [.TRACK_KEY_TYPE: "login"])
```

**环境变量类型定义**：
```swift
public typealias ComposableTracking = (String, [String: Any]?) -> Void
```

### 3. 埋点规范

#### 埋点命名规则
- **强制使用3段式命名**：`page_component_action`
- **page**：页面名称（如 home, onboarding, karaoke）
- **component**：组件名称（如 button, banner, list）
- **action**：操作类型（一般只能写 click，特殊情况可使用 show, close, complete 等）

#### 埋点参数规则
埋点参数的 key **只能使用** 预定义的 TrackKey 常量：

```swift
// 可用的 TrackKey 列表：
.TRACK_KEY_INT1        // 整数参数1
.TRACK_KEY_INT2        // 整数参数2
.TRACK_KEY_INT3        // 整数参数3
.TRACK_KEY_INT4        // 整数参数4
.TRACK_KEY_INT5        // 整数参数5

.TRACK_KEY_STRING1     // 字符串参数1
.TRACK_KEY_STRING2     // 字符串参数2
.TRACK_KEY_STRING3     // 字符串参数3
.TRACK_KEY_STRING4     // 字符串参数4
.TRACK_KEY_STRING5     // 字符串参数5

.TRACK_KEY_ID          // ID 标识
.TRACK_KEY_FROM        // 来源页面
.TRACK_KEY_VALUE       // 数值
.TRACK_KEY_CONTENT     // 内容描述
.TRACK_KEY_TYPE        // 类型标识
```

#### 埋点示例
```swift
// 正确示例
tracking("home_button_click", params: [
    .TRACK_KEY_TYPE: "start_singing",
    .TRACK_KEY_FROM: "home"
])

tracking("karaoke_score_show", params: [
    .TRACK_KEY_VALUE: 85,
    .TRACK_KEY_ID: "song_123"
])

// 错误示例 - 不要使用
tracking("button_click", params: ["type": "login"])  // ❌ 不是3段式
tracking("home_button_tap", params: ["button_id": "login"])  // ❌ 使用了未定义的key
```

### 4. 导航系统

#### Navigator 现代化 API
```swift
// 推荐使用 - 针对 ComposablePageComponent
Navigator.push(page: animated:from:)
Navigator.pushReplace(page: animated:from:)
Navigator.present(page: animated:from:)

// 已废弃 - 旧版 GLSwiftUIPageTrackable
@available(*, deprecated, renamed: "push(_:animated:from:)", message: "please use composable page component to push")
Navigator.push(_:animated:from:) where Content: View&GLSwiftUIPageTrackable
```

### 5. 代码模板

#### 普通 UI 组件模板
```swift
// Props 结构体定义
struct [ComponentName]Props {
    // 必需属性（使用 let）
    let title: String
    let data: [DataType]

    // 可选属性（提供默认值）
    var style: StyleType = .default
    var isEnabled: Bool = true

    // 回调函数（使用可选类型）
    var onAction: ((ActionType) -> Void)?
    var onComplete: (() -> Void)?
}

struct [ComponentName]: ComposableUIComponent {
    // MARK: - ComposableUIComponent Protocol
    typealias ComponentProps = [ComponentName]Props

    let props: ComponentProps

    init(props: ComponentProps) {
        self.props = props
    }

    // MARK: - State Variables
    @State private var localState: StateType = defaultValue
    @Environment(\.tracking) private var tracking

    // MARK: - Body
    var body: some View {
        // UI 实现
    }

    // MARK: - Private Views
    private var subView: some View {
        // 子视图实现
    }

    private func itemView(item: ItemType) -> some View {
        // 列表项视图
    }

    // MARK: - Private Methods
    private func handleAction() {
        // 事件追踪 - 使用3段式命名和预定义的 TrackKey
        tracking("page_component_click", [
            .TRACK_KEY_TYPE: "[ComponentName]",
            .TRACK_KEY_FROM: "page_name"
        ])

        // 业务逻辑处理
        props.onAction?(actionData)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    [ComponentName](props: [ComponentName]Props(
        title: "示例标题",
        data: sampleData,
        onAction: { _ in print("Action triggered") }
    ))
}
#endif
```

#### 页面组件模板（推荐使用 ViewModel）
```swift
// ViewModel 定义
class [PageName]ViewModel: ComposableViewModel {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var data: [DataType] = []

    // MARK: - Public Methods
    func loadData() {
        isLoading = true
        // 加载数据逻辑
        // 完成后调用事件追踪
        tracking("page_data_show", [
            .TRACK_KEY_FROM: "[PageName]",
            .TRACK_KEY_TYPE: "load_complete"
        ])
    }

    func handleButtonTap() {
        tracking("page_button_click", [
            .TRACK_KEY_TYPE: "main_action",
            .TRACK_KEY_FROM: "[PageName]"
        ])
        // 处理点击逻辑
    }
}

// Props 结构体（如果需要外部参数）
struct [PageName]Props {
    let initialData: [DataType]?
    var showHeader: Bool = true
}

struct [PageName]: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = [PageName]Props

    let props: ComponentProps

    init(props: ComponentProps) {
        self.props = props
        viewModel = [PageName]ViewModel()
    }

    var pageName: String { "[PageName]" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "[PageName]",
            .TRACK_KEY_TYPE: "[FeatureName]"
        ]
    }

    // MARK: - State Variables
    @ObservedObject private var viewModel: [PageName]ViewModel

    // MARK: - Body
    var body: some View {
        VStack {
            if props.showHeader {
                headerView
            }

            contentView
        }
        .connect(viewModel: viewModel) // 连接 ViewModel
    }

    // MARK: - Private Views
    private var headerView: some View {
        // 头部视图
    }

    private var contentView: some View {
        // 内容视图
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    [PageName](props: [PageName]Props(
        initialData: sampleData,
        showHeader: true
    ))
}
#endif
```

#### 无参数组件模板
```swift
struct [ComponentName]: ComposableUIComponent {
    // MARK: - ComposableUIComponent Protocol
    // 无需定义 ComponentProps，使用默认的 Void

    // MARK: - State Variables
    @State private var localState: StateType = defaultValue

    // MARK: - Body
    var body: some View {
        // UI 实现
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    [ComponentName]() // 使用无参数初始化
}
#endif
```

### 6. 最佳实践

#### Props 设计原则
- **不可变性优先**：核心属性使用 `let` 声明
- **合理默认值**：可选配置提供明智的默认值
- **类型安全**：使用枚举而非字符串常量
- **回调语义化**：回调函数名称清晰表达意图
- **参数传递**：回调传递必要的上下文信息

#### 状态管理规则
- **页面状态**：使用 `ComposableViewModel` + `@ObservedObject`
- **组件内部状态**：使用 `@State` 管理
- **外部数据**：通过 Props 传入，不在组件内创建
- **环境依赖**：使用 `@Environment(\.tracking)`

#### ViewModel 连接
- **ViewModel 连接**：使用 `.connect(viewModel: viewModel)` 连接 ViewModel
- **事件传递**：ViewModel 通过 `trackingEventPublisher` 将事件传递给环境变量

#### 导航和追踪
- **事件追踪**：使用 ViewModel 中的 `tracking()` 或环境变量，严格遵循3段式命名和 TrackKey 规范
- **VIP 页面**：使用 ViewModel 中的 `showVipPage(from:)`
- **用户信息**：使用 ViewModel 中的 `userInfo()` 获取用户状态

#### 代码组织顺序
严格按照以下顺序组织代码：
1. ViewModel 定义（如适用）
2. Props 结构体定义
3. 协议实现（typealias, props, init）
4. 页面属性（pageName, pageTrackingParams）
5. 状态变量声明
6. body 主视图
7. 私有视图组件
8. 私有方法
9. Preview 代码

#### 命名约定
- **组件名称**：`[Feature][Purpose]Component`（如 `OnboardingSelectionComponent`）
- **页面名称**：`[Feature]Page`（如 `OnboardingPage`）
- **ViewModel**：`[PageName]ViewModel`
- **Props 名称**：`[ComponentName]Props`

### 7. 特殊情况处理

#### 双向绑定
当需要双向数据绑定时，Props 中可以包含 `@Binding`：
```swift
struct InputComponentProps {
    let title: String
    @Binding var text: String
    var onTextChange: ((String) -> Void)?
}
```

#### 复杂 Props
对于复杂组件，将 Props 拆分为子结构：
```swift
struct ComplexComponentProps {
    let headerConfig: HeaderConfig
    let contentConfig: ContentConfig
    let actionConfig: ActionConfig
}
```

#### 用户信息获取
在 ViewModel 中获取用户信息：
```swift
let userInfo = userInfo()
if userInfo.isVip {
    // VIP 用户逻辑
}
```

### 8. 质量检查清单

在完成组件编写后，确保：
- [ ] 实现了正确的协议
- [ ] Props 结构体设计合理
- [ ] 页面组件使用了 ViewModel 模式
- [ ] 正确使用了 `.connect(viewModel:)` 修饰符
- [ ] 使用了环境变量进行事件追踪
- [ ] 埋点使用3段式命名规范
- [ ] 埋点参数只使用预定义的 TrackKey 常量
- [ ] 代码按标准顺序组织
- [ ] 使用了正确的 MARK 注释
- [ ] 提供了预览代码
- [ ] 私有成员使用了 `private` 修饰符

### 9. 迁移现有组件

当需要将现有 SwiftUI View 迁移为 Composable UI 组件时：

1. **提取 Props**：将原 View 的属性提取到 Props 结构体
2. **创建 ViewModel**：如果是页面组件，创建对应的 ViewModel，一般的UI组件不需要 ViewModel维护状态
3. **迁移状态**：将 `@State` 变量移到 ViewModel 中作为 `@Published`
4. **更新引用**：将直接属性访问改为 `props.xxx` 或 `viewModel.xxx`
5. **实现协议**：添加必要的协议实现代码
6. **添加连接**：使用 `.connect(viewModel: viewModel)` 连接
7. **更新预览**：使用新的 Props 初始化方式
8. **规范化埋点**：将原有埋点改为3段式命名，使用预定义的 TrackKey 常量

## 注意事项

1. **线程安全**：UI 相关操作必须在主线程执行
2. **内存管理**：注意避免循环引用，特别是 delegate 模式
3. **版本兼容**：确保 iOS 版本兼容性，特别是新的 SwiftUI 特性
4. **测试验证**：新版本转化页需要充分测试，包括各种边缘情况
5. **导航优先级**：优先使用 `ComposablePageComponent` 的导航方法，避免使用已废弃的 `GLSwiftUIPageTrackable` API

---
*本文档原位于 HackWeek/Incubator/CLAUDE.md，已迁移至 DOCS/API.md*