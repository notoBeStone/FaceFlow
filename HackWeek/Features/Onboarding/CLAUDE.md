[根目录](../../../CLAUDE.md) > [Features](../) > **Onboarding**

# Onboarding 模块

## 模块职责
Onboarding 模块负责新用户的首次引导流程，包括用户信息收集、语言设置和应用功能介绍。

## 入口与启动

### 主要入口文件
- **OnboardingManager.swift**: 单例管理器，控制 Onboarding 流程状态
- **OnboardingRootView.swift**: SwiftUI 主视图，处理整个 Onboarding 流程

### 启动逻辑
应用启动时，`OnboardingManager` 会检查用户是否已完成 Onboarding：
```swift
// 检查是否需要显示 Onboarding
if OnboardingManager.shouldShowOnboarding() {
    // 显示 Onboarding 流程
    OnboardingManager.showIfNeeded()
}
```

## 对外接口

### OnboardingManager 公开接口
- `shouldShowOnboarding() -> Bool`: 检查是否需要显示 Onboarding
- `showIfNeeded(completion: (() -> Void)? = nil)`: 按需显示 Onboarding
- `getUserPreferences() -> [String: Any]?`: 获取用户偏好设置
- `resetOnboarding()`: 重置 Onboarding 状态（仅调试用）

### OnboardingData 数据模型
```swift
struct OnboardingData: Codable {
    let ageGroup: String        // 用户年龄段
    let targetLanguage: String  // 目标学习语言
    let createdAt: Date        // 创建时间
    let isCompleted: Bool      // 是否已完成
}
```

## 关键依赖与配置

### 依赖项
- **SwiftUI**: UI 框架
- **Foundation**: 基础框架
- **UserDefaults**: 本地数据存储

### 配置信息
- **UserDefaults Keys**:
  - `HackWords_OnboardingCompleted`: 完成状态标识
  - `HackWords_UserPreferences`: 用户偏好设置
  - `HackWords_OnboardingData`: 完整的 Onboarding 数据

## 数据模型

### OnboardingAgeGroup 枚举
```swift
enum OnboardingAgeGroup: String, CaseIterable {
    case under18 = "<18"
    case age18to25 = "18-25"
    case age25to35 = "25-35"
    case age35to55 = "35-55"
    case over55 = "55+"
}
```

### OnboardingLanguage 枚举
```swift
enum OnboardingLanguage: String, CaseIterable {
    case spanish = "Spanish"
    case chinese = "中文"
    case japanese = "日本語"

    var languageCode: String { /* 返回 ISO 语言代码 */ }
}
```

## 视图组件

### 主要视图
- **OnboardingRootView**: 主容器视图，管理页面流程
- **OnboardingWelcomePage**: 欢迎页面
- **OnboardingAgePage**: 年龄选择页面
- **OnboardingChooseLanguagePage**: 语言选择页面

### 页面导航
使用 SwiftUI 的 `TabView` 实现页面切换，通过 `@State` 管理当前页面索引。

## 测试与质量

### 建议的测试覆盖
- [ ] OnboardingManager 状态管理测试
- [ ] OnboardingData 序列化/反序列化测试
- [ ] 页面导航流程测试
- [ ] 用户选择数据持久化测试

### 质量检查项
- ✅ 数据模型设计合理
- ✅ 错误处理完善
- ✅ 用户数据本地存储
- ❌ 缺少单元测试
- ❌ 缺少 UI 测试

## 常见问题 (FAQ)

### Q: 如何重置 Onboarding 状态？
A: 调用 `OnboardingManager.shared.resetOnboarding()`，仅用于调试目的。

### Q: 用户数据存储在哪里？
A: 使用 `UserDefaults` 本地存储，包括完成状态和用户偏好设置。

### Q: 如何添加新的语言选项？
A: 在 `OnboardingLanguage` 枚举中添加新的 case，并提供对应的 `languageCode`。

### Q: Onboarding 完成后如何跳转到主应用？
A: 通过 `TemplateAPI.Navigator.present(MainAppView(), from: "onboarding")` 跳转。

## 相关文件清单

### 核心文件
- `OnboardingManager.swift` - 流程管理器
- `OnboardingData.swift` - 数据模型
- `OnboardingRootView.swift` - 主视图
- `OnboardingWelcomePage.swift` - 欢迎页面
- `OnboardingAgePage.swift` - 年龄选择页面
- `OnboardingChooseLanguagePage.swift` - 语言选择页面

### 依赖关系
- **依赖模块**: Incubator/ViewStack (导航)
- **被依赖模块**: Features/WordBook (主应用)
- **外部依赖**: UserDefaults (数据存储)

## 变更记录 (Changelog)

### 2025-10-16
- 创建 Onboarding 模块文档
- 分析现有代码结构和依赖关系
- 确定测试缺口和质量改进项

### 历史变更
- 参见 SPRINT_ARCHIVE/001_Original_TODO_List.md