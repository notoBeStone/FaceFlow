[根目录](../../../CLAUDE.md) > [Features](../) > **VipConversion**

# VipConversion 模块

## 模块职责
VipConversion 模块负责 HackWords 应用的付费转化系统，包括会员订阅管理、支付流程处理、SKU 配置和提醒功能。

## 入口与启动

### 主要入口文件
- **TrialableVipConversionPage.swift**: 试用版会员转化页面
- **HistoryVipConversionView.swift**: 历史版会员转化页面
- **VipConversionViewModel.swift**: 转化页面业务逻辑

### 启动逻辑
转化页面的显示时机：
1. **Onboarding 完成后**: 非VIP用户完成用户引导流程
2. **功能限制时**: 用户使用高级功能时触发转化
3. **手动触发**: 用户主动升级会员时

```swift
// 显示转化页面的方式
PaywallNotifier.shared.showPaywall(from: "onboarding_completion")
```

## 对外接口

### PaywallNotifier 核心接口
```swift
class PaywallNotifier {
    static let shared = PaywallNotifier()

    // 显示付费墙
    func showPaywall(from source: String)

    // 改变提醒设置
    func changeReminder(to enabled: Bool, completion: @escaping (Bool) -> Void)
}
```

### VipConversionViewModel 业务接口
```swift
class VipConversionViewModel: ObservableObject {
    // SKU 管理
    func fetchSkus() async
    func selectSku(_ skuId: String)

    // 购买流程
    func purchaseButtonTapped()
    func restoreButtonTapped()

    // 页面导航
    func openTerms()
    func openPrivacy()
    func openSubscriptionTerms()
}
```

## 关键依赖与配置

### 支付系统
- **StoreKit**: iOS 原生支付框架
- **GLPurchaseUIExtension**: 购买UI扩展库
- **PaywallNotifier**: 付费墙通知系统

### 外部依赖
- **SwiftUI**: UI 框架
- **Foundation**: 基础框架
- **UserNotifications**: 推送通知框架
- **GLWidget**: 自定义UI组件

### 配置信息
- **SKU 配置**: 在 `AppConfigMisc.swift` 中配置商品ID
- **提醒功能**: 本地推送通知权限
- **订阅状态**: 通过 GLAccountExtension 获取

## 数据模型

### ConversionSku 商品模型
```swift
struct ConversionSku: Identifiable {
    let id: String
    let skuId: String          // 商品标识符
    let product: SKProduct     // StoreKit 产品对象
    let trialDays: Int         // 试用天数
    let period: SkuPeriod     // 订阅周期
    let sortIndex: Int         // 排序索引
}

enum SkuPeriod: String {
    case weekly, monthly, yearly, seasonly, halfYearly, none
}
```

### VipConversionViewModel 状态
```swift
@Published var skus: [ConversionSku] = []           // 可用商品列表
@Published var selectedSkuId: String? = nil        // 选中的商品ID
@Published var reminderEnable: Bool = false        // 提醒开关状态
@Published var isLoading: Bool = false             // 加载状态
```

## 视图组件

### 主要视图结构
- **TrialableVipConversionPage**:
  - 渐变背景和头部图片
  - 功能特性列表展示
  - SKU 选择界面（试用版）
  - 购买按钮和提醒设置
  - 条款和政策链接

- **HistoryVipConversionView**:
  - 历史版UI设计
  - 相似的商品选择逻辑
  - 兼容旧版用户界面

### UI 组件
- **skuSelectionView**: 商品选择视图
- **purchaseHint**: 价格提示组件
- **reminderView**: 提醒设置组件
- **termsAndPolicyView**: 条款政策组件

### 设备适配
- **iPad 适配**: 使用不同的图片资源和尺寸
- **响应式布局**: 根据屏幕尺寸调整UI元素
- **安全区域**: 处理不同设备的安全区域

## 核心功能

### 1. 商品管理
```swift
// 启用当前可用的SKU
PaywallNotifier.shared.enableCurrentSkus(viewModel.availableSkus)

// 异步获取商品信息
await viewModel.fetchSkus()
```

### 2. 购买流程
```swift
// 开始购买流程
TemplateAPI.Conversion.startPurchase(sku.skuId, trialable: sku.trialDays > 0)

// 恢复购买
TemplateAPI.Conversion.restorePurchase()
```

### 3. 提醒功能
```swift
// 改变提醒设置
PaywallNotifier.shared.changeReminder(to: newValue) { granted in
    DispatchQueue.main.async {
        viewModel.reminderEnable = granted && newValue
    }
}
```

### 4. 条款和政策
- **使用条款**: `TemplateAPI.Conversion.showTermsOfUse()`
- **隐私政策**: `TemplateAPI.Conversion.showPrivacyPolicy()`
- **订阅条款**: `TemplateAPI.Conversion.showSubscriptionTerms()`

## 测试与质量

### 建议的测试覆盖
- [ ] VipConversionViewModel 状态管理测试
- [ ] SKU 获取和选择逻辑测试
- [ ] 购买流程集成测试
- [ ] 提醒功能测试
- [ ] 不同设备尺寸的UI测试
- [ ] 网络异常处理测试

### 质量检查项
- ✅ 支付流程集成完整
- ✅ UI设计响应式适配
- ✅ 错误处理机制完善
- ✅ 多设备兼容性良好
- ❌ 缺少单元测试
- ❌ 缺少UI测试
- ❌ 缺少支付流程测试

### 已知问题
- 网络异常时的商品加载失败处理
- 订阅状态同步延迟问题
- 某些地区的支付方式限制

## 常见问题 (FAQ)

### Q: 如何添加新的订阅方案？
A: 在 `AppConfigMisc.swift` 的 `AppEvoConfig.skuConfig` 中添加新的 `AppSkuConfigModel`。

### Q: 试用期的逻辑如何处理？
A: 通过 `sku.trialDays > 0` 判断是否为试用期，并在UI中显示相应的价格和提示。

### Q: 提醒功能是如何实现的？
A: 使用 `UserNotifications` 框架设置本地推送，提醒用户试用即将结束。

### Q: 如何处理购买失败的情况？
A: 在 `VipConversionViewModel` 中统一处理购买结果，显示错误信息并提供重试选项。

### Q: 订阅状态如何同步？
A: 通过 `GLAccountExtension` 获取用户的VIP状态，并在应用启动时同步。

### Q: 支持哪些支付方式？
A: 通过 StoreKit 支持 App Store 所有支付方式，包括信用卡、Apple Pay、运营商计费等。

## 相关文件清单

### 核心文件
- `TrialableVipConversionPage.swift` - 试用版转化页面
- `HistoryVipConversionView.swift` - 历史版转化页面
- `VipConversionViewModel.swift` - 转化页面业务逻辑

### 配置文件
- `AppConfigMisc.swift` - SKU 和支付配置

### 依赖关系
- **依赖模块**: Incubator/ViewStack (导航), GLPurchaseUIExtension (支付)
- **外部依赖**: StoreKit (支付), UserNotifications (推送通知)
- **被依赖模块**: Features/Onboarding (引导流程), Features/WordBook (功能触发)

## 变更记录 (Changelog)

### 2025-10-16
- 创建 VipConversion 模块详细文档
- 更新支付系统从 TemplateAPI.Conversion 到 PaywallNotifier
- 优化转化页面作为转化系统展示功能

### 历史变更
- ✅ 付费转化页功能 - SPRINT_ARCHIVE/002_Paid_Conversion_Page_Implementation.md
- ✅ 转化页面优化和bug修复 - 多次迭代更新
- ✅ iPad 适配和响应式设计改进
- ✅ 提醒功能和推送通知集成
- ✅ SKU 配置系统实现
- ✅ 支付流程错误处理优化