# Onboarding 模块

## 模块职责

Onboarding 模块负责新用户的首次引导流程，包括用户信息收集、语言设置和应用功能介绍。该模块展示了导航系统的核心功能，是用户体验的第一站。

## 模块结构

```
HackWeek/Features/Onboarding/
├── README.md                    # 本文档
├── CLAUDE.md                    # AI 开发辅助文档
├── OnboardingManager.swift      # 流程管理器
├── OnboardingRootView.swift     # SwiftUI 主视图
├── OnboardingWelcomePage.swift  # 欢迎页面
├── OnboardingAgePage.swift      # 年龄选择页面
└── OnboardingChooseLanguagePage.swift # 语言选择页面
```

## 核心组件详解

### 1. OnboardingManager (流程管理器)

#### 职责
- 管理 Onboarding 流程状态
- 处理用户偏好设置存储
- 提供流程控制接口

#### 核心接口
```swift
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()

    // 检查是否需要显示 Onboarding
    static func shouldShowOnboarding() -> Bool

    // 按需显示 Onboarding
    func showIfNeeded(completion: (() -> Void)? = nil)

    // 获取用户偏好设置
    func getUserPreferences() -> [String: Any]?

    // 重置 Onboarding 状态
    func resetOnboarding()
}
```

#### 使用示例
```swift
// 应用启动时检查
if OnboardingManager.shouldShowOnboarding() {
    OnboardingManager.shared.showIfNeeded()
}

// 获取用户设置
if let preferences = OnboardingManager.shared.getUserPreferences() {
    let language = preferences["targetLanguage"] as? String
    let ageGroup = preferences["ageGroup"] as? String
}
```

### 2. OnboardingRootView (主视图)

#### 职责
- 管理整个 Onboarding 流程
- 处理页面间导航
- 集成导航系统演示

#### 核心特性
- 使用 SwiftUI 的 `TabView` 实现页面切换
- 通过 `@State` 管理当前页面索引
- 集成 Navigator 导航系统

#### 导航演示功能
```swift
// 展示 Push 导航
Navigator.push(NextPage(), from: "onboarding_welcome")

// 展示 Present 导航
Navigator.present(DetailView(), from: "onboarding_age")

// 展示 Replace 导航
Navigator.pushReplace(MainAppView(), from: "onboarding_complete")
```

### 3. 页面组件

#### OnboardingWelcomePage
- **功能**: 欢迎页面，介绍应用功能
- **交互**: 开始按钮引导用户进入下一步

#### OnboardingAgePage
- **功能**: 年龄段选择
- **组件**: 年龄选项按钮组
- **数据**: 选择结果存储到 OnboardingData

#### OnboardingChooseLanguagePage
- **功能**: 目标学习语言选择
- **组件**: 语言选项列表
- **国际化**: 支持多语言显示

## 数据模型

### OnboardingData
```swift
struct OnboardingData: Codable {
    let ageGroup: String        // 用户年龄段
    let targetLanguage: String  // 目标学习语言
    let createdAt: Date        // 创建时间
    let isCompleted: Bool      // 是否已完成
}
```

### 年龄段枚举
```swift
enum OnboardingAgeGroup: String, CaseIterable {
    case under18 = "<18"
    case age18to25 = "18-25"
    case age25to35 = "25-35"
    case age35to55 = "35-55"
    case over55 = "55+"
}
```

### 语言选择枚举
```swift
enum OnboardingLanguage: String, CaseIterable {
    case spanish = "Spanish"
    case chinese = "中文"
    case japanese = "日本語"

    var languageCode: String { /* 返回 ISO 语言代码 */ }
}
```

## 导航系统集成

Onboarding 模块是导航系统功能的完整展示：

### 1. 页面栈导航
```swift
// Push 导航到下一个页面
Navigator.push(OnboardingAgePage(), from: "onboarding_welcome")
```

### 2. 模态导航
```swift
// Present 显示详细信息
Navigator.present(LanguageInfoView(), from: "onboarding_language")
```

### 3. 页面替换
```swift
// Replace 导航到主应用
Navigator.pushReplace(MainAppView(), from: "onboarding_complete")
```

### 4. 自动埋点
所有导航调用都自动集成埋点追踪：
```swift
// 自动生成追踪事件
// page: onboarding_welcome
// action: navigation_push
// target: onboarding_age
```

## 存储系统

### UserDefaults 配置
- **HackWords_OnboardingCompleted**: 完成状态标识
- **HackWords_UserPreferences**: 用户偏好设置
- **HackWords_OnboardingData**: 完整的 Onboarding 数据

### 数据持久化
```swift
// 保存用户偏好
UserDefaults.standard.set(true, forKey: "HackWords_OnboardingCompleted")

// 保存完整数据
let data = OnboardingData(ageGroup: "25-35", targetLanguage: "Spanish", createdAt: Date(), isCompleted: true)
let encoded = try JSONEncoder().encode(data)
UserDefaults.standard.set(encoded, forKey: "HackWords_OnboardingData")
```

## 生命周期管理

### 流程控制
1. **启动检查**: 应用启动时检查是否需要显示
2. **流程执行**: 用户按步骤完成信息收集
3. **完成处理**: 保存数据并跳转到主应用
4. **重置支持**: 提供调试用的重置功能

### 状态管理
```swift
@Published var currentStep: OnboardingStep = .welcome
@Published var onboardingData: OnboardingData?
@Published var isCompleted: Bool = false
```

## 使用指南

### 集成到应用
```swift
// 在 TemplateConfig.swift 中配置
struct TemplateConfig {
    static var rootView: AnyView {
        return AnyView(OnboardingRootView())
    }
}

// 配置启动时显示转化页
static var showConversionAtLaunch: Bool {
    return UserDefaults.standard.bool(forKey: "HackWords_OnboardingCompleted")
}
}
```

### 自定义流程
```swift
// 添加新的页面步骤
enum OnboardingStep {
    case welcome
    case age
    case language
    case permissions  // 新增步骤
    case complete
}

// 自定义页面顺序
private func navigateToNextStep() {
    switch currentStep {
    case .welcome:
        currentStep = .age
    case .age:
        currentStep = .language
    case .language:
        currentStep = .permissions  // 新增
    case .permissions:
        currentStep = .complete
    case .complete:
        completeOnboarding()
    }
}
```

## 测试建议

### 单元测试
- [ ] OnboardingManager 状态管理测试
- [ ] OnboardingData 序列化/反序列化测试
- [ ] 用户偏好设置存储测试

### UI 测试
- [ ] 页面导航流程测试
- [ ] 用户输入交互测试
- [ ] 完成流程测试

### 集成测试
- [ ] 与导航系统集成测试
- [ ] 数据持久化测试
- [ ] 主应用跳转测试

## 最佳实践

### 1. 状态管理
- 使用 `@Published` 属性确保 UI 响应式更新
- 集中管理 Onboarding 状态避免分散

### 2. 错误处理
- 提供优雅的错误处理机制
- 记录关键操作日志便于调试

### 3. 用户体验
- 提供清晰的进度指示
- 支持返回到上一步操作
- 合理的动画和过渡效果

### 4. 数据安全
- 敏感数据加密存储
- 提供数据导出功能
- 遵循隐私保护原则

## 常见问题

### Q: 如何修改 Onboarding 流程顺序？
A: 修改 `OnboardingRootView` 中的导航逻辑，调整页面切换顺序。

### Q: 如何添加新的用户信息收集？
A: 创建新的页面组件，添加相应的数据模型字段，更新导航流程。

### Q: 如何重置 Onboarding 状态？
A: 调用 `OnboardingManager.shared.resetOnboarding()` 方法。

### Q: 如何自定义页面样式？
A: 修改各个 Page 组件的 SwiftUI 视图代码，或创建自定义样式组件。

---

*Onboarding 模块为用户提供友好的首次体验，同时展示了导航系统的核心功能。*