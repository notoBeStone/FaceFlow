[根目录](../../../CLAUDE.md) > [Features](../) > **WordBook**

# WordBook 模块

## 模块职责
WordBook 模块是 HackWords 应用的核心功能模块，负责单词学习的完整流程，包括拍照识别、单词管理、学习计划和数据持久化。

## 入口与启动

### 主要入口文件
- **MainAppView.swift**: 主应用界面，显示单词汇总和导航
- **CameraPage.swift**: 拍照界面，用于捕获和识别物体
- **WordBookPage.swift**: 单词本详情页面
- **IdentificationPage.swift**: 图片识别和单词提取页面

### 启动流程
1. 应用启动后进入 `MainAppView`
2. 用户点击拍照按钮跳转到 `CameraPage`
3. 拍照完成后进入 `IdentificationPage` 进行AI识别
4. 识别结果保存到对应的 `WordBook`
5. 返回主界面查看新添加的单词

## 对外接口

### WordBookManager 核心接口
```swift
class WordBookManager: ObservableObject {
    static let shared = WordBookManager()

    // 获取所有单词本
    func getWordBooks() -> [WordBook]

    // 根据日期获取单词本
    func getWordBook(for date: Date) -> WordBook?

    // 创建新单词本
    func createWordBook(for date: Date) -> WordBook

    // 添加单词到单词本
    func addWord(_ word: WordModel, to wordBook: WordBook)
}
```

### Navigation 接口
- `Navigator.present(CameraPage(), from: "main_app")`: 打开相机
- `Navigator.present(IdentificationPage(), from: "camera")`: 进入识别页面
- `Navigator.present(WordBookPage(), from: "main_app")`: 查看单词本详情

## 关键依赖与配置

### 数据持久化
- **SwiftData**: 使用 Core Data 进行本地数据存储
- **WordBook 模型**: 按天组织的单词本容器
- **WordModel 模型**: 单个单词的完整信息

### 外部依赖
- **GLCamera**: 相机功能支持 (通过 TemplateAPI)
- **AI 服务**: 图片识别和单词提取
- **SwiftUI**: UI 框架
- **Foundation**: 基础框架

### 配置文件
- **相机权限**: Info.plist 中的 NSCameraUsageDescription
- **图片处理**: 自动缩放至 320x320 像素以内

## 数据模型

### WordBook 模型
```swift
@Model
final class WordBook {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var recordDate: Date  // 按天组织
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var words: [WordModel] = []

    var wordCount: Int { return words.count }
    var masteredWordCount: Int { /* 掌握单词数量 */ }
}
```

### WordModel 模型
```swift
@Model
final class WordModel {
    @Attribute(.unique) var id: UUID
    var imageData: Data              // 处理后的图片数据
    var targetLanguage: String       // 目标语言
    var word: String                 // 识别出的单词
    var masteryLevel: Int            // 掌握程度 (0-5)
    var notes: String                // 用户备注

    // 学习计划字段
    var nextReviewDate: Date         // 下次复习日期
    var reviewInterval: Int          // 复习间隔
    var reviewCount: Int             // 复习次数
    var lastReviewDate: Date?        // 上次复习日期
}
```

### 学习算法
使用简化的遗忘曲线算法，复习间隔：`[0, 1, 2, 4, 7, 15]` 天

## 视图组件

### 主要视图结构
- **MainAppView**:
  - 显示问候语和单词统计
  - 大相机拍照按钮
  - 按日期分组的单词本列表
  - 设置页面入口

- **CameraPage**:
  - 相机预览界面
  - 拍照控制按钮
  - 相机切换和闪光灯控制

- **IdentificationPage**:
  - 拍照结果预览
  - AI 识别进度指示
  - 单词提取结果显示
  - 保存或重拍选项

- **WordBookPage**:
  - 单词本详情展示
  - 单词列表管理
  - 学习状态查看
  - 复习功能入口

### UI 组件
- **DailyWordSection**: 日期分组显示组件
- **WordImageThumbnail**: 单词图片缩略图
- **WordThumbnail**: 单词缩略图（备用）

## 测试与质量

### 建议的测试覆盖
- [ ] WordBookManager 数据操作测试
- [ ] WordModel 学习算法测试
- [ ] 图片处理功能测试
- [ ] 相机功能集成测试
- [ ] AI 识别流程测试
- [ ] SwiftData 持久化测试

### 质量检查项
- ✅ 数据模型设计完整
- ✅ 学习算法实现正确
- ✅ 图片处理优化到位
- ✅ 错误处理基本完善
- ❌ 缺少单元测试
- ❌ 缺少 UI 测试
- ❌ 缺少集成测试

### 已知问题
- AI 识别服务集成需要进一步测试
- 离线模式下功能受限
- 大量数据时的性能优化待验证

## 常见问题 (FAQ)

### Q: 图片存储为什么限制在 320x320 像素？
A: 为了平衡图片质量和存储空间，同时满足 AI 识别的要求。

### Q: 学习算法的间隔是如何确定的？
A: 基于艾宾浩斯遗忘曲线的简化版本：1天、2天、4天、7天、15天。

### Q: 如何处理识别错误的单词？
A: 在 WordBookPage 中可以编辑单词内容和添加备注。

### Q: 数据是否支持云端同步？
A: 当前版本仅支持本地存储，云端同步功能待开发。

### Q: 如何导出学习数据？
A: 可通过 WordBookManager 的数据接口实现导出功能。

## 相关文件清单

### 核心文件
- `MainAppView.swift` - 主应用界面
- `CameraPage.swift` - 拍照界面
- `IdentificationPage.swift` - 识别界面
- `WordBookPage.swift` - 单词本详情
- `CameraViewModel.swift` - 相机业务逻辑
- `IdentificationViewModel.swift` - 识别业务逻辑

### 数据层
- `Models/WordBook.swift` - 单词本数据模型
- `Models/WordModel.swift` - 单词数据模型
- `Managers/WordBookManager.swift` - 数据管理器
- `Data/WordBookDataContainer.swift` - 数据容器

### 视图组件
- `Views/WordBookExampleView.swift` - 示例视图

### 依赖关系
- **依赖模块**: Incubator/ViewStack (导航), Incubator/ConversionMisc (转化)
- **外部依赖**: GLCamera (相机), AI服务 (识别)
- **数据存储**: SwiftData/Core Data

## 变更记录 (Changelog)

### 2025-10-16
- 创建 WordBook 模块详细文档
- 分析数据模型和业务逻辑
- 确定测试缺口和质量改进项

### 历史变更
- ✅ 单词本存储和管理 - SPRINT_ARCHIVE/004_WordBook_Storage_And_Management.md
- ✅ 简化版学习计划 - SPRINT_ARCHIVE/005_Simplified_Learning_Plan_Implementation.md
- ✅ 主界面UI实现 - SPRINT_ARCHIVE/006_Main_App_UI_Implementation.md
- ✅ 单词本UI改进 - SPRINT_ARCHIVE/007_WordBook_UI_Bug_Fixes_And_Improvements.md
- ✅ 拍照识别功能 - SPRINT_ARCHIVE/003_Camera_Identification_Implementation.md