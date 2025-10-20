# VipConversion 模块

## 模块职责

VipConversion 模块负责付费转化系统，是应用商业化的重要组成部分。该模块展示了企业级付费转化的完整实现，包括付费墙展示、SKU 管理、转化流程追踪等功能。

## 模块结构

```
HackWeek/Features/VipConversion/
├── README.md                    # 本文档
├── TrialableVipConversionPage.swift  # 主要转化页面
├── VipConversionViewModel.swift      # 转化业务逻辑
├── HistoryVipConversionView.swift    # 历史用户转化页面
└── ../TrialCancelSurveyView.swift    # 试用取消调查页面
```

## 核心组件详解

### 1. TrialableVipConversionPage (主要转化页面)

#### 职责
- 展示付费转化界面
- 处理用户购买流程
- 集成企业级付费系统

#### 核心功能
- ✅ 试用和付费选项展示
- ✅ 功能特性介绍
- ✅ 用户评价和社会证明
- ✅ 购买流程引导

#### 使用示例
```swift
// 在 TemplateConfig 中配置
struct TemplateConfig {
    static var conversionView: AnyView {
        AnyView(TrialableVipConversionPage())
    }
}

// 手动触发付费墙
PaywallNotifier.shared.showVip(from: "word_book_limit")
```

### 2. VipConversionViewModel (业务逻辑)

#### 职责
- 管理转化状态
- 处理 SKU 配置
- 集成购买系统

#### 核心接口
```swift
@MainActor
class VipConversionViewModel: ObservableObject {
    @Published var availableSkus: [String] = []
    @Published var selectedSku: String?
    @Published var isLoading: Bool = false

    // 加载可用 SKU
    func loadAvailableSkus()

    // 开始购买流程
    func startPurchase(skuId: String, trialable: Bool)

    // 恢复购买
    func restorePurchase()
}
```

### 3. HistoryVipConversionView (历史用户页面)

#### 职责
- 为历史 VIP 用户提供特殊优惠
- 展示重新订阅选项
- 处理特殊转化逻辑

#### 目标用户
- 曾经订阅但已过期的用户
- 需要特殊优惠策略的用户群体

## 付费系统集成

### 企业级依赖
```swift
import GLPurchaseUI          // 付费 UI 组件
import GLPurchaseExtension   // 付费功能扩展
import GLAccountExtension    // 账户系统扩展
import GLConfig_Extension    // 配置扩展
import GLCore               // 核心功能库
```

### ConversionMisc 集成
```swift
// 基础转化控制器
class MyVipConversionPage: BasicConversionController {
    override func setupMainUI() {
        // 自定义转化页 UI
    }
}

// 付费墙通知
PaywallNotifier.shared.showVip(from: "conversion_source", animationType: .present)
```

### SKU 配置系统
```swift
// AppConfigMisc.swift 中的配置
struct AppEvoConfig {
    static var skuConfig: [AppSkuConfigModel] {
        [
            .init(skuId: "premium_yearly", period: .yearly, trialDays: 0, category: .none, skuLevel: .gold),
            .init(skuId: "premium_weekly_trial", period: .weekly, trialDays: 3, category: .freeTrail, skuLevel: .gold),
            // 更多 SKU 配置...
        ]
    }
}
```

## 转化流程设计

### 1. 触发机制
```swift
// 启动时自动展示
TemplateConfig.showConversionAtLaunch

// 功能限制触发
if userReachedFreeLimit {
    PaywallNotifier.shared.showVip(from: "feature_limit")
}

// 用户主动触发
Button("升级到 Premium") {
    PaywallNotifier.shared.showVip(from: "user_initiated")
}
```

### 2. 转化页面类型
- **新用户转化**: 试用期 + 付费订阅
- **历史用户转化**: 特殊优惠回归
- **功能升级转化**: 高级功能解锁

### 3. 购买流程
```swift
// 1. 展示转化页
PaywallNotifier.shared.showVip(from: source)

// 2. 用户选择 SKU
TemplateAPI.Conversion.enableCurrentSkus(["sku1", "sku2"])

// 3. 开始购买
TemplateAPI.Conversion.startPurchase("premium_yearly", trialable: true)

// 4. 处理购买结果
func purchaseCompleted() {
    // 解锁功能
    // 更新用户状态
    // 追踪转化事件
}
```

## 数据追踪和分析

### 转化事件追踪
```swift
// 页面展示追踪
tracking("vip_conversion_show", [
    .TRACK_KEY_SOURCE: "word_book_limit",
    .TRACK_KEY_TYPE: "free_trial_offer"
])

// 购买按钮点击追踪
tracking("vip_purchase_click", [
    .TRACK_KEY_SKU: "premium_yearly",
    .TRACK_KEY_TRIALABLE: true
])

// 转化完成追踪
tracking("vip_conversion_success", [
    .TRACK_KEY_REVENUE: 19.99,
    .TRACK_KEY_SKU: "premium_yearly"
])
```

### A/B 测试集成
```swift
// 获取 A/B 测试配置
let memo = GL().ABTesting_ValueForKey("conversion_page", activate: false) ?? "default_memo"

// 显示不同版本的转化页
switch memo {
case "default_memo":
    // 默认版本
case "trial_focus_memo":
    // 试用重点版本
case "discount_memo":
    // 优惠重点版本
default:
    // 默认处理
}
```

## 用户界面设计

### 转化页面元素
```swift
VStack {
    // 标题区域
    TitleView(text: "解锁全部功能")

    // 功能特性列表
    FeaturesListView(features: [
        "无限拍照识别",
        "高级学习算法",
        "云端同步",
        "无广告体验"
    ])

    // 价格展示
    PricingView(skus: availableSkus)

    // 用户评价
    TestimonialsView(reviews: userReviews)

    // CTA 按钮
    CTAButton(title: "开始免费试用") {
        startPurchase()
    }

    // 信任标识
    TrustBadgesView(badges: ["App Store 推荐", "100万+ 用户"])
}
```

### 响应式设计
- iPad 和 iPhone 适配
- 不同屏幕尺寸优化
- 横屏和竖屏支持

## 购买后处理

### 功能解锁
```swift
func unlockPremiumFeatures() {
    // 1. 更新用户状态
    UserDefaults.standard.set(true, forKey: "isPremiumUser")

    // 2. 解锁功能限制
    FeatureFlags.premiumFeaturesEnabled = true

    // 3. 刷新界面
    refreshUI()

    // 4. 追踪转化成功
    tracking("premium_features_unlocked")
}
```

### 账户同步
```swift
// 同步到 GL 账户系统
GL().Account_SetVipInfo(vipInfo)

// 更新本地状态
updateLocalUserStatus()

// 刷新相关界面
NotificationCenter.default.post(name: .vipStatusChanged, object: nil)
```

## 试用取消处理

### TrialCancelSurveyView
```swift
struct TrialCancelSurveyView: View {
    @State private var selectedReason: CancelReason?
    @State private var feedback: String = ""

    var body: some View {
        VStack {
            Text("为什么取消试用？")
                .font(.title2)
                .padding()

            // 取消原因选项
            ForEach(CancelReason.allCases, id: \.self) { reason in
                CancelReasonRow(reason: reason) {
                    selectedReason = reason
                }
            }

            // 详细反馈
            TextField("请告诉我们更多信息...", text: $feedback)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 提交按钮
            Button("提交反馈") {
                submitFeedback()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
```

### 挽回策略
```swift
// 优惠挽留
func showRetentionOffer() {
    let discountOffer = DiscountOffer(
        originalPrice: 19.99,
        discountPrice: 9.99,
        duration: 30
    )
    PaywallNotifier.shared.showVip(from: "retention_offer")
}

// 功能限制提醒
func showFeatureLimitReminder() {
    Alert(
        title: "需要升级",
        message: "此功能需要 Premium 订阅",
        primaryButton: .default("升级") {
            PaywallNotifier.shared.showVip(from: "feature_limit_alert")
        },
        secondaryButton: .cancel("取消")
    )
}
```

## 配置和管理

### SKU 管理
```swift
// 动态加载 SKU 配置
func loadSKUs() {
    let config = AppEvoConfig.skuConfig
    availableSkus = config.map { $0.skuId }
}

// 根据 A/B 测试调整 SKU
func adjustSKUsForABTest() {
    let testGroup = ABTesting.getGroup("sku_pricing_test")
    switch testGroup {
    case "discount_group":
        enableDiscountedSKUs()
    case "premium_group":
        enablePremiumSKUs()
    default:
        enableDefaultSKUs()
    }
}
```

### 转化配置
```swift
struct ConversionConfig {
    static let defaultMemo = "vip_conversion_page"
    static let historyMemo = "history_vip_conversion"

    // 转化触发条件
    static let freeLimitCount = 10
    static let conversionShowFrequency = 2 // 每日最多2次

    // 试用期配置
    static let defaultTrialDays = 7
    static let extendedTrialDays = 14
}
```

## 测试策略

### A/B 测试
- [ ] 不同转化页面设计测试
- [ ] 价格策略测试
- [ ] CTA 按钮文案测试
- [ ] 试用期长度测试

### 功能测试
- [ ] 购买流程完整性测试
- [ ] SKU 配置正确性测试
- [ ] 账户状态同步测试
- [ ] 退款处理测试

### 用户体验测试
- [ ] 转化页面加载性能测试
- [ ] 不同设备适配测试
- [ ] 网络异常情况测试
- [ ] 用户权限测试

## 性能优化

### 页面加载优化
- 预加载转化页资源
- 缓存 SKU 配置信息
- 异步加载用户评价

### 购买流程优化
- 减少购买步骤
- 优化表单验证
- 快速响应操作反馈

## 常见问题

### Q: 如何添加新的 SKU 配置？
A: 在 AppConfigMisc.swift 的 skuConfig 数组中添加新的 AppSkuConfigModel。

### Q: 如何自定义转化页 UI？
A: 继承 BasicConversionController 并重写 setupMainUI() 方法。

### Q: 如何处理购买失败？
A: 在 VipConversionViewModel 中实现错误处理逻辑，提供用户友好的错误提示。

### Q: 如何集成第三方支付系统？
A: 通过 TemplateAPI.Conversion 协议扩展，添加新的支付方式支持。

---

*VipConversion 模块展示了企业级付费转化系统的完整实现，是应用商业化的重要组件。*