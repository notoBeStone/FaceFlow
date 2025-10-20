# Survey 模块 - 取消订阅问卷

## 📋 模块概述

取消订阅问卷模块负责在用户取消订阅、试用即将过期或已过期时，收集用户反馈，帮助产品优化。通过疲劳度控制机制，确保用户不被重复打扰。

## 🎯 功能特性

- ✅ **智能触发**：自动检测用户会员状态，在合适时机展示问卷
- ✅ **疲劳度控制**：确保同类型问卷只展示一次
- ✅ **用户体验优先**：延迟展示，避免与其他启动流程冲突
- ✅ **完整埋点**：追踪展示、关闭、提交等所有用户行为
- ✅ **架构规范**：符合 HackWeek ComposablePageComponent 架构

## 🏗️ 架构设计

```
MainAppView (首页)
    ↓ onAppear 检查
SurveyFatigueManager (疲劳度管理器)
    ↓ shouldShowSurvey()
Navigator.present()
    ↓
TrialCancelSurveyPage (包装组件)
    ↓
TrialCancelSurveyView (UI 实现)
```

## 📁 文件结构

```
HackWeek/Features/Survey/
├── SurveyFatigueManager.swift      # 疲劳度管理器（单例）
├── TrialCancelSurveyPage.swift     # 问卷页面包装组件
└── README.md                       # 本文档

HackWeek/Features/
└── TrialCancelSurveyView.swift     # 问卷 UI 实现（已有）

HackWeek/Features/WordBook/
└── MainAppView.swift               # 首页集成点
```

## 🔑 核心组件

### 1. SurveyFatigueManager

**职责**：管理问卷展示频率和历史记录

**关键方法**：
```swift
// 检查是否应该展示问卷
func shouldShowSurvey() -> Bool

// 记录问卷已展示
func markSurveyShown(type: SurveyCancelType? = nil)

// 记录用户提交
func markSurveySubmitted()

// 记录用户关闭
func markSurveyDismissed()

// 重置状态（测试用）
func resetState()
```

**存储机制**：
- 使用 `UserDefaults` 持久化存储
- 记录已展示的问卷类型、提交状态、关闭次数等

### 2. TrialCancelSurveyPage

**职责**：符合 ComposablePageComponent 的页面组件包装

**Props**：
```swift
struct TrialCancelSurveyPageProps {
    let surveyType: SurveyCancelType    // 问卷类型
    let onDismiss: (() -> Void)?        // 关闭回调
}
```

**特性**：
- 自动集成页面追踪
- 处理展示、关闭、提交的生命周期
- 调用 SurveyFatigueManager 记录用户行为

### 3. TrialCancelSurveyView

**职责**：问卷 UI 实现（已有组件，已增强）

**增强点**：
- 新增 `onDismissAction` 回调
- 新增 `onSubmitAction` 回调
- 支持外部控制关闭逻辑

### 4. SurveyCancelType

**职责**：定义问卷触发类型（已有枚举）

**类型**：
```swift
enum SurveyCancelType {
    case trialCancelled  // 试用期取消
    case expireSoon      // 即将过期（7天内）
    case expired         // 已过期
    case unknown         // 未知/不触发
}
```

## 📊 使用示例

### 基本使用（首页自动触发）

问卷会在 `MainAppView` 加载时自动检查并展示，无需手动调用。

### 手动触发（可选）

```swift
// 检查是否应该展示
if SurveyFatigueManager.shared.shouldShowSurvey() {
    let surveyType = SurveyFatigueManager.shared.getCurrentSurveyType()
    
    Navigator.present(
        TrialCancelSurveyPage(
            props: TrialCancelSurveyPageProps(
                surveyType: surveyType,
                onDismiss: {
                    print("问卷已关闭")
                }
            )
        ),
        from: "custom_page"
    )
}
```

### 重置状态（测试）

```swift
// 清除所有记录，重新触发问卷（仅用于开发测试）
SurveyFatigueManager.shared.resetState()
```

### 查看历史记录

```swift
let history = SurveyFatigueManager.shared.getHistory()
print(history)
// 输出：
// 问卷历史记录:
// - 已展示类型: trialCancelled, expireSoon
// - 最后展示时间: 2025-10-16 10:30:00
// - 已提交: true
// - 关闭次数: 2
```

## 🧪 测试指南

### 测试用例

| 测试场景 | 操作步骤 | 预期结果 |
|---------|---------|---------|
| **首次试用取消** | 1. 重置状态<br>2. 模拟试用取消<br>3. 启动应用 | 延迟1.5秒后展示问卷 |
| **首次即将过期** | 1. 重置状态<br>2. 模拟7天内过期<br>3. 启动应用 | 延迟1.5秒后展示问卷 |
| **首次已过期** | 1. 重置状态<br>2. 模拟会员已过期<br>3. 启动应用 | 延迟1.5秒后展示问卷 |
| **二次进入** | 1. 首次展示后关闭<br>2. 重新启动应用 | 不再展示问卷 |
| **提交后** | 1. 提交问卷<br>2. 重新启动应用 | 不再展示问卷 |
| **未满足条件** | 1. 正常会员状态<br>2. 启动应用 | 不展示问卷 |

### 测试步骤

#### 1. 重置测试状态

```swift
// 在调试代码中调用（或使用 Xcode 断点执行）
SurveyFatigueManager.shared.resetState()
```

#### 2. 模拟会员状态

由于问卷触发依赖 `GL().Account_*` 系列接口，需要：
- 使用测试账号（试用会员、即将过期会员、已过期会员）
- 或者修改 `SurveyCancelType` 的判断逻辑进行测试

#### 3. 验证展示逻辑

- 启动应用，进入 `MainAppView`
- 等待 1.5 秒
- 观察是否弹出问卷

#### 4. 验证埋点

使用抓包工具或 Firebase/Analytics 后台查看事件：
- `survey_cancel_show`：问卷展示
- `survey_cancel_dismiss`：问卷关闭
- `trialcancelsurvey_submit_click`：问卷提交

### 调试技巧

#### 查看控制台日志

在 DEBUG 模式下，`SurveyFatigueManager` 会输出详细日志：
```
🎯 [SurveyFatigueManager] 问卷应该展示: type = trialCancelled
🎯 [SurveyFatigueManager] 已记录问卷展示: type = trialCancelled
🎯 [SurveyFatigueManager] 已记录用户关闭问卷，关闭次数: 1
```

#### 断点调试位置

1. `MainAppView.checkAndShowSurvey()` - 检查触发逻辑
2. `SurveyFatigueManager.shouldShowSurvey()` - 验证判断条件
3. `TrialCancelSurveyPage.onAppear` - 确认页面展示

## 📈 埋点事件

### 1. survey_cancel_show
**触发时机**：问卷展示时
**参数**：
- `type`: 问卷类型（trialCancelled / expireSoon / expired）
- `from`: 来源页面（main_app）

### 2. survey_cancel_dismiss
**触发时机**：用户点击"Not Now"关闭问卷
**参数**：
- `type`: 问卷类型
- `content`: not_now

### 3. trialcancelsurvey_submit_click
**触发时机**：用户提交问卷
**参数**：
- `content`: 用户选择和反馈内容（格式：reason1:feedback1;reason2:feedback2）

## ⚙️ 配置参数

### 展示延迟时间

当前设置为 **1.5 秒**，可在 `MainAppView.checkAndShowSurvey()` 中调整：
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    showSurvey()
}
```

### 问卷触发条件

在 `SurveyCancelType` 中定义：
- **试用取消**：试用会员 && 未自动续订
- **即将过期**：付费会员 && 未自动续订 && 7天内过期
- **已过期**：历史会员 || 试用已过期

## 🔧 故障排查

### 问题：问卷没有展示

**可能原因**：
1. 未满足触发条件（检查会员状态）
2. 已展示过相同类型（检查历史记录）
3. 用户已提交过问卷（检查提交状态）
4. 延迟时间内页面已关闭

**解决方法**：
```swift
// 1. 查看历史记录
print(SurveyFatigueManager.shared.getHistory())

// 2. 重置状态
SurveyFatigueManager.shared.resetState()

// 3. 检查会员状态
let type = SurveyFatigueManager.shared.getCurrentSurveyType()
print("当前问卷类型: \(type)")

// 4. 检查是否应该展示
let should = SurveyFatigueManager.shared.shouldShowSurvey()
print("是否应该展示: \(should)")
```

### 问题：问卷重复展示

**可能原因**：
1. `hasSurveyChecked` 状态未正确管理
2. UserDefaults 存储失败

**解决方法**：
- 检查 `MainAppView` 的 `@State` 变量
- 验证 UserDefaults 读写权限

### 问题：埋点未上报

**可能原因**：
1. GLMPTracking 未正确初始化
2. 网络问题
3. 参数格式错误

**解决方法**：
- 检查 Analytics 配置
- 使用抓包工具验证网络请求
- 查看控制台错误日志

## 🚀 未来优化方向

### Phase 2
- [ ] 支持服务端配置展示逻辑
- [ ] 增加问卷展示间隔配置（如30天后可再次展示）
- [ ] A/B 测试支持
- [ ] 多语言支持

### Phase 3
- [ ] 个性化问卷（基于用户画像）
- [ ] 激励机制（提供优惠券）
- [ ] 可视化数据分析后台
- [ ] 流失预警系统

## 📚 相关文档

- [CLAUDE.md](../../../CLAUDE.md) - 项目整体架构
- [Navigator 使用指南](../../../Documentation/Guides/Navigator_Usage_Guide.md)
- [VipConversion 模块](../../../Documentation/Modules/VipConversion/README.md)

## 🤝 贡献指南

如需修改此模块：
1. 遵循 HackWeek 架构规范
2. 使用 ComposablePageComponent 协议
3. 确保埋点完整
4. 添加必要的测试用例
5. 更新本文档

---

**创建时间**: 2025-10-16  
**最后更新**: 2025-10-16  
**维护者**: AI Assistant  
**版本**: v1.0

