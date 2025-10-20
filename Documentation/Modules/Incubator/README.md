# Incubator 模块

## 模块概述

Incubator 模块是 HackWeek 项目的基础设施层，提供了核心的导航系统、UI 组件、转化功能和工具类。这些组件为上层 Features 模块提供支撑，体现了企业级架构的设计思想。

## 模块结构

```
HackWeek/Incubator/
├── README.md                    # 本文档
├── ViewStack/                   # 导航和组件系统
│   ├── Navigator.swift         # 统一导航管理器
│   ├── ComposableUI.swift      # 可组合 UI 组件协议
│   └── ComposableEnv.swift     # 环境变量系统
├── ConversionMisc.swift         # 转化系统相关功能
├── CommonEventObserver.swift    # 生命周期事件观察者
├── UI.swift                     # UI 组件和扩展
└── UIExtention.swift            # UI 扩展功能
```

## 核心组件详解

### 1. ViewStack 导航系统

#### Navigator.swift
- **职责**: 统一的页面导航管理
- **核心功能**:
  - Push 导航: 标准页面栈跳转
  - Present 导航: 模态页面展示
  - Popup 导航: 底部弹窗功能
  - Replace 导航: 页面替换功能
- **特性**: 自动埋点追踪、类型安全保证、主线程安全

#### ComposableUI.swift
- **职责**: 可组合 UI 组件协议定义
- **核心协议**:
  - `ComposableUIComponent`: 基础组件协议
  - `ComposablePageComponent`: 页面级组件协议
- **设计模式**: Props 模式，支持类型安全的参数传递

#### ComposableEnv.swift
- **职责**: 环境变量系统
- **核心功能**: 提供追踪等环境变量注入
- **使用方式**: `@Environment(\.tracking) private var tracking`

### 2. 转化系统 (ConversionMisc.swift)

#### PaywallNotifier
- **职责**: 付费墙通知和管理
- **核心功能**:
  - 显示付费墙页面
  - 管理转化流程
  - 处理 SKU 配置
- **集成**: 与 GLPurchaseUI 深度集成

#### BasicConversionController
- **职责**: SwiftUI 转化页基础控制器
- **核心功能**:
  - 生命周期管理
  - UI 事件处理
  - 转化流程控制
- **设计**: 开放类设计，支持自定义转化页

### 3. 事件系统 (CommonEventObserver.swift)

#### ViewControllerEventObserver
- **职责**: ViewController 生命周期事件观察
- **核心事件**:
  - viewDidLoad/viewWillAppear
  - viewDidAppear/viewWillDisappear
  - viewDidDisappear
- **使用场景**: SwiftUI 中的生命周期监听

#### ConversionEventObserver
- **职责**: 转化页专用事件观察
- **继承**: 继承自 ViewControllerEventObserver
- **扩展事件**: updateUIEvent 等 UI 更新事件

### 4. UI 组件系统

#### UI.swift
- **职责**: 基础 UI 组件
- **核心组件**:
  - `RoundedCorner`: 圆角形状组件
  - 其他基础 UI 组件

#### UIExtention.swift
- **职责**: UI 扩展功能
- **功能**: 为 SwiftUI 提供额外的 UI 能力

## 依赖关系

### 外部依赖
```swift
import GLPurchaseUI      // 付费转化 UI
import GLMP              // 模板框架
import GLCore            // 核心功能库
import GLConfig_Extension // 配置扩展
import GLResource        // 资源管理
import GLUtils           # 工具函数库
import AppConfig         # 应用配置
import GLAccountExtension # 账户扩展
```

### 被依赖模块
- **Features/Onboarding**: 使用 ViewStack 导航系统
- **Features/WordBook**: 使用 ViewStack 和事件系统
- **Features/VipConversion**: 使用 ConversionMisc 转化系统

## 使用指南

### 导航系统使用
```swift
// 推送页面
Navigator.push(MyPage(props: myProps), from: "home")

// 模态展示
Navigator.present(SettingsView(), from: "main")

// 弹窗展示
Navigator.showPopup(PopupView(), targetHeight: 300)
```

### 可组合组件使用
```swift
struct MyPage: ComposablePageComponent {
    struct Props {
        let title: String
        let onTap: () -> Void
    }

    let props: Props
    var pageName: String { "my_page" }

    var body: some View {
        VStack {
            Text(props.title)
            Button("Action") { props.onTap() }
        }
    }
}
```

### 转化系统使用
```swift
// 显示付费墙
PaywallNotifier.shared.showVip(from: "home_page")

// 自定义转化页
class MyConversionPage: BasicConversionController {
    open override func setupMainUI() {
        // 自定义 UI 设置
    }
}
```

### 事件监听使用
```swift
struct MyView: View {
    @EnvironmentObject var eventObserver: ViewControllerEventObserver

    var body: some View {
        Text("Hello")
            .onReceive(eventObserver.viewWillAppearEvent) {
                print("View will appear")
            }
    }
}
```

## 设计原则

### 1. 单一职责原则
- 每个组件都有明确的职责边界
- ViewStack 专注于导航，ConversionMisc 专注于转化

### 2. 开放封闭原则
- 通过协议和基类提供扩展点
- 支持自定义而不需要修改核心代码

### 3. 依赖倒置原则
- 依赖抽象而非具体实现
- 通过协议定义组件接口

### 4. 最小知识原则
- 模块间保持松耦合
- 通过明确的 API 进行交互

## 最佳实践

### 1. 导航使用
- 优先使用 Navigator 的静态方法
- 明确指定来源参数用于追踪
- 使用 ComposablePageComponent 确保类型安全

### 2. 组件设计
- 遵循 Props 模式设计组件参数
- 实现适当的协议以获得支持
- 保持组件的单一职责

### 3. 事件处理
- 使用环境对象进行生命周期监听
- 避免强引用导致的内存泄漏
- 合理使用 Combine 框架

### 4. 转化功能
- 继承 BasicConversionController 实现自定义转化页
- 正确实现 PaywallNotifierDelegate 协议
- 注意生命周期管理

## 扩展指南

### 添加新的导航类型
1. 在 Navigator.swift 中添加新的静态方法
2. 确保线程安全和错误处理
3. 添加相应的埋点追踪

### 创建新的 UI 组件
1. 在 UI.swift 中定义新的组件
2. 遵循 SwiftUI 的设计原则
3. 提供清晰的使用示例

### 扩展转化功能
1. 继承 BasicConversionController 创建新的转化页
2. 实现必要的协议方法
3. 添加自定义的事件处理

---

*Incubator 模块为 HackWeek 提供稳定的基础设施支撑，是整个架构的核心基石。*