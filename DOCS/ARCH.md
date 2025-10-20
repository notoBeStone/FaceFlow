 这是一个团队内部的 iOS App 模板项目，通过该模板可以进行简单的配置实现快速的 App 创建和开发。

#  目录和访问规则
- 主要源代码：位于当前目录及子目录下
- 忽略 Deprecated 目录，该目录隐藏了大部分模板工程接口的详细实现，但并未结构化，没有良好的注释
- 参考 Incubator 目录，这个目录暴露了所有模板工程可以使用的接口，包含但不限于视图栈、通用 UI 方法和配置、UI编码规范、Paywall 编写方法等。
- 静态资源位于 Resources 目录，按照资源类型分目录存放
- App 入口位于 AppDelegate.swift，启动流程实现隐藏在了 Deprecated 目录中，无特定情况不予修改

#  项目架构详细说明

## 核心目录结构
- **Incubator/** - 公共接口层，暴露所有模板工程可使用的接口
  - `ViewStack/` - 视图栈管理系统，包含 Navigator.swift、ComposableUI.swift、ComposableEnv.swift
  - `UI.swift` - 通用 UI 组件和扩展（如 RoundedCorner）
  - `UIExtention.swift` - UI 扩展功能
  - `CommonEventObserver.swift` - 通用事件观察者
  - `ConversionMisc.swift` - 转换相关功能

- **Deprecated/** - 核心实现层（不建议直接修改）
  - `Common/` - 通用组件实现
    - `Extension/` - 基础扩展（Foundation、SwiftUI、UIKit、ThirdParty）
    - `Manager/` - 管理器类（如 DeeplinkHandleManager）
    - `Protocol/` - 协议定义
    - `UI/` - UI 组件实现
    - `Utils/` - 工具类
  - `Modules/` - 功能模块实现
    - `Launch/` - 启动相关
    - `Push/` - 推送相关
    - `Setting/` - 设置相关

- **Resources/** - 静态资源目录
  - `Assets.xcassets/` - 图片资源，按功能模块组织
    - `Common/` - 通用图标（导航栏、弹窗等）
    - `Settings/` - 设置页面相关图标
  - `Fonts/` - 字体文件（如 Montserrat）
  - `jsons/` - JSON 配置文件
    - 应用数据文件（fish_names.json、plants_names.json、tank_data.json）
  - `bundle/` - Bundle 资源文件
    - AI 提示词和响应模板（prompt_*.json、response_*.json）
  - `en.lproj/` - 英文本地化资源
  - `Base.lproj/` - 基础本地化资源

- **Features/** - 功能模块目录
  - 各业务功能的具体实现

- **Views/** - 视图组件目录

- **Tracking/** - 数据追踪相关

- **SupportingFiles/** - 项目支持文件

- **AquaAIData.xcdatamodeld/** - Core Data 数据模型

## 核心接口说明


### Navigator 视图栈管理 (Incubator/ViewStack/Navigator.swift)
提供统一的页面导航能力：
- `push(_:animated:from:)` - 页面入栈
- `pushReplace(_:animated:from:)` - 替换当前页面
- `present(_:animated:from:)` - 模态展示
- `pop(_:)` - 页面出栈
- `dismiss(_:completion:)` - 关闭模态
- `showPopup(_:animated:targetHeight:completion:)` - 显示弹窗
- `dismissPopup(_:completion:)` - 关闭弹窗

### ComposableUI 组件系统 (Incubator/ViewStack/ComposableUI.swift)
提供可组合的 UI 组件架构：
- `ComposableUIComponent` - UI 组件基础协议
- `ComposablePageComponent` - 页面组件协议
- `AnyComposableHostingController` - 类型擦除的 Hosting Controller

### 页面追踪协议 (Incubator/ViewStack/Navigator.swift)
- `GLSwiftUIPageTrackable` - 页面追踪协议
- 提供页面生命周期追踪能力（onFirstAppear、onPageExit）

## 开发规范

### 页面开发
- 使用 `ComposablePageComponent` 协议创建页面组件
- 实现 `GLSwiftUIPageTrackable` 协议进行页面追踪
- 通过 `Navigator` 进行页面跳转管理

### 资源管理
- 图片资源按功能模块分类存放在 Assets.xcassets 中
- JSON 配置文件统一存放在 jsons 目录
- 字体文件存放在 Fonts 目录
- Bundle 资源（如 AI 提示词）存放在 bundle 目录

## API 使用示例

### Onboarding 使用方式

```swift
// 检查是否需要显示 Onboarding
if OnboardingManager.shouldShowOnboarding() {
    // 显示 Onboarding 流程
    OnboardingManager.showOnboarding {
        print("Onboarding completed")
    }
}

// 或者使用便捷方法自动判断并显示
OnboardingManager.showIfNeeded()

// 获取用户偏好设置
if let preferences = OnboardingManager.getUserPreferences() {
    let ageGroup = preferences["selectedAgeGroup"] as? String
    let language = preferences["selectedLanguage"] as? String
}

// 重置 Onboarding（仅用于调试）
OnboardingManager.resetOnboarding()
```

### 应用启动集成

在应用启动时，可以调用：
```swift
// AppDelegate 或应用启动逻辑中
OnboardingManager.showIfNeeded()
```

### 注意事项
- AppDelegate.swift 中的 `TemplateWrapper` 调用为模板代码，请勿修改
- Deprecated 目录中的实现细节不建议直接依赖，应通过 Incubator 接口使用
- 新增功能应优先考虑在 Features 目录下创建模块
- Onboarding 数据自动保存在 UserDefaults 中，键名为 `HackWords_OnboardingCompleted` 和 `HackWords_UserPreferences`

---
*本文档原位于 HackWeek/CLAUDE.md，已迁移至 DOCS/ARCH.md*
