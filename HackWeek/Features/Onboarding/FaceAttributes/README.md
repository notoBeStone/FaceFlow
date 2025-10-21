# 面部属性 Onboarding 流程

## 📋 概述

这是一个完整的面部属性收集 Onboarding 流程，用于了解用户的脸型、五官和肤质特征，以便为用户推荐个性化的美妆内容。

## 🎯 功能特点

### 三个阶段
1. **了解脸型** (4个问题)
   - 脸型、颧骨高低、下颌线类型、下巴形状

2. **了解五官** (8个问题)
   - 眼睛大小、眼睛形状、眼距、眉形
   - 鼻子长度、鼻子宽度
   - 嘴唇厚度、嘴唇形状

3. **了解肤质** (3个问题)
   - 肤质类型、肤色、年龄范围

### 用户体验
- ✅ 每个问题都配有直观的图片选项
- ✅ 阶段间有鼓励页面激励用户
- ✅ 流畅的页面过渡动画
- ✅ 实时进度显示
- ✅ 支持跳过单个问题
- ✅ 自动保存到 SwiftData

## 📁 文件结构

```
FaceAttributes/
├── FaceAttributesOnboardingFlow.swift          # 流程管理器（数据模型）
├── FaceAttributesOnboardingContainer.swift     # 主容器视图
├── AttributeSelectionPage.swift                # 问题选择页面
├── EncouragementPage.swift                     # 阶段鼓励页面
├── AttributeImagePlaceholder.swift             # 图片占位符组件
└── README.md                                   # 本文档
```

## 🚀 使用方式

### 集成到 Onboarding 流程

已在 `OnboardingRootView.swift` 中集成，流程如下：

```
欢迎页 → 年龄选择 → 语言选择 → 面部属性收集 → 完成
```

### 独立使用

```swift
FaceAttributesOnboardingContainer {
    // 完成后的处理
    print("用户属性收集完成")
}
```

### 读取用户属性

```swift
struct MyView: View {
    @Query private var userAttributes: [UserFaceAttributes]
    
    var body: some View {
        if let attrs = userAttributes.first {
            Text("脸型: \(attrs.faceShape ?? "未设置")")
            Text("肤色: \(attrs.skinTone ?? "未设置")")
            
            // 获取所有标签用于视频推荐
            let tags = attrs.getAllTags()
            // ["Oval", "DoubleLid", "WarmFair", ...]
        }
    }
}
```

## 🎨 添加真实图片

### 当前状态
- 目前使用 `AttributeImagePlaceholder` 作为占位符
- 显示渐变背景 + SF Symbols 图标
- 开发模式下显示图片名称

### 替换为真实图片

#### 1. 准备图片资源

将图片添加到 `Assets.xcassets`，命名规则：

**脸型类 (face_)**
- `face_round` - 圆形脸
- `face_oval` - 椭圆形脸
- `face_square` - 方形脸
- `face_oblong` - 长形脸
- `face_heart` - 心形脸
- `face_inverted_triangle` - 倒三角脸

**颧骨类 (cheekbone_)**
- `cheekbone_high` - 高颧骨
- `cheekbone_normal` - 正常颧骨
- `cheekbone_low` - 低颧骨

**下颌线类 (jawline_)**
- `jawline_round` - 圆润下颌线
- `jawline_sharp` - 尖锐下颌线
- `jawline_square` - 方形下颌线
- `jawline_defined` - 下颌角明显

**下巴类 (chin_)**
- `chin_pointed` - 尖下巴
- `chin_round` - 圆下巴
- `chin_wide` - 宽下巴

**眼睛大小类 (eye_size_)**
- `eye_size_small` - 小眼睛
- `eye_size_normal` - 正常眼睛
- `eye_size_large` - 大眼睛

**眼睛形状类 (eye_shape_)**
- `eye_shape_monolid` - 单眼皮
- `eye_shape_double` - 双眼皮
- `eye_shape_inner` - 内双
- `eye_shape_puffy` - 肿泡眼

**眼距类 (eye_distance_)**
- `eye_distance_wide` - 眼距宽
- `eye_distance_normal` - 眼距正常
- `eye_distance_narrow` - 眼距窄

**眉形类 (eyebrow_)**
- `eyebrow_straight` - 平眉
- `eyebrow_curved` - 弯眉
- `eyebrow_arched` - 拱形眉
- `eyebrow_angular` - 剑眉

**鼻子长度类 (nose_length_)**
- `nose_length_short` - 短鼻
- `nose_length_normal` - 正常鼻长
- `nose_length_long` - 长鼻

**鼻子宽度类 (nose_width_)**
- `nose_width_narrow` - 窄鼻
- `nose_width_normal` - 正常鼻宽
- `nose_width_wide` - 宽鼻

**嘴唇厚度类 (lips_thickness_)**
- `lips_thickness_thin` - 薄唇
- `lips_thickness_medium` - 适中唇
- `lips_thickness_thick` - 厚唇

**嘴唇形状类 (lips_shape_)**
- `lips_shape_top` - 上厚下薄
- `lips_shape_bottom` - 下厚上薄
- `lips_shape_balanced` - 厚薄均匀

**肤质类 (skin_type_)**
- `skin_type_dry` - 干性肤质
- `skin_type_oily` - 油性肤质
- `skin_type_normal` - 中性肤质
- `skin_type_combination` - 混合肤质
- `skin_type_sensitive` - 敏感肤质

**肤色类 (skin_tone_)**
- `skin_tone_cool` - 冷白皮
- `skin_tone_warm` - 暖白皮
- `skin_tone_natural` - 自然肤色
- `skin_tone_healthy` - 健康肤色
- `skin_tone_wheat` - 小麦肤色

**年龄类 (age_)**
- `age_under18` - 18岁以下
- `age_19_25` - 19-25岁
- `age_26_35` - 26-35岁
- `age_36_45` - 36-45岁
- `age_over45` - 45岁以上

**总计：56 张图片**

#### 2. 修改 AttributeImagePlaceholder.swift

替换占位符为真实图片：

```swift
struct AttributeImagePlaceholder: View {
    let imageName: String
    
    var body: some View {
        // 尝试加载真实图片
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // 如果图片不存在，显示占位符
            ZStack {
                backgroundGradient
                iconView
            }
        }
    }
    
    // ... 保留原有的占位符代码
}
```

### 图片设计建议

- **尺寸**: 建议 300x300 pt (@2x: 600x600px, @3x: 900x900px)
- **格式**: PNG 或 JPEG
- **风格**: 简洁、卡通化、一致性强
- **背景**: 透明或纯色
- **内容**: 清晰展示面部特征，避免过于写实

## 📊 数据流

```
用户选择
    ↓
FaceAttributesOnboardingFlow.selectedAnswers (临时存储)
    ↓
完成所有问题
    ↓
FaceAttributesOnboardingContainer.saveUserAttributes()
    ↓
SwiftData 持久化存储
    ↓
UserFaceAttributes 模型
```

## 🎭 页面流程

```
问题1 → 问题2 → 问题3 → 问题4 (脸型阶段)
                             ↓
                        鼓励页面 😊
                             ↓
问题5 → 问题6 → ... → 问题12 (五官阶段)
                             ↓
                        鼓励页面 👁️
                             ↓
问题13 → 问题14 → 问题15 (肤质阶段)
                             ↓
                        完成页面 ✨
```

## 🔧 自定义配置

### 修改问题

编辑 `FaceAttributesOnboardingFlow.swift` 中的 `stages` 数组：

```swift
AttributeQuestion(
    id: "customQuestion",
    question: "你的问题？",
    subtitle: "副标题说明",
    options: [
        AttributeOption(
            id: "option1",
            title: "选项标题",
            imageName: "custom_image",
            value: "EnumValue"
        )
    ],
    attributeType: .faceShape
)
```

### 修改颜色主题

在 `AttributeSelectionPage.swift` 中修改：

```swift
// 主色调
Color(hex: "FF6B9D")

// 背景渐变
LinearGradient(
    colors: [Color(hex: "FFF5F7"), Color.white],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### 修改动画效果

在各个页面的 `.animation()` 修饰符中调整：

```swift
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: ...)
```

## 🐛 调试

### 查看收集的数据

```swift
// 在完成后打印
flow.selectedAnswers
// ["faceShape": "Oval", "eyeShape": "DoubleLid", ...]
```

### 检查保存的数据

```swift
let descriptor = FetchDescriptor<UserFaceAttributes>()
let attributes = try? modelContext.fetch(descriptor)
print(attributes?.first?.getAllTags())
```

### 重置 Onboarding

```swift
// 清除完成标记
UserDefaults.standard.set(false, forKey: "HackWords_OnboardingCompleted")

// 删除用户属性
let descriptor = FetchDescriptor<UserFaceAttributes>()
if let attrs = try? modelContext.fetch(descriptor) {
    attrs.forEach { modelContext.delete($0) }
    try? modelContext.save()
}
```

## 📱 截图占位符

目前使用渐变色背景 + SF Symbols 图标作为占位符，效果如下：
- 脸型：粉色渐变 + face.smiling 图标
- 五官：绿色/橙色渐变 + 相应图标
- 肤质：米色/桃色渐变 + 相应图标

## ✅ 后续改进

- [ ] 添加真实的插画图片
- [ ] 支持从服务器动态加载问题配置
- [ ] 添加图片预览和放大功能
- [ ] 支持多选（某些问题）
- [ ] 添加"不确定"选项
- [ ] 支持返回上一题修改答案
- [ ] 本地化多语言支持

## 📞 相关文档

- [数据模型定义](../MainTab/Models/UserFaceAttributes.swift)
- [SwiftData 使用](../../../Documentation/Guides/DataPersistence_Usage_Guide.md)
- [项目规范](../../../../CLAUDE.md)

