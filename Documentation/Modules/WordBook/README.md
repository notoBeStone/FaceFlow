# WordBook 模块

## 模块职责

WordBook 模块是 HackWords 应用的核心功能模块，展示了四大核心能力的综合应用：拍照功能、LLM 调用、数据持久化和导航系统。该模块实现了完整的单词学习流程，从拍照识别到单词本管理。

## 模块结构

```
HackWeek/Features/WordBook/
├── README.md                    # 本文档
├── CLAUDE.md                    # AI 开发辅助文档
├── MainAppView.swift            # 主应用界面
├── CameraPage.swift             # 拍照界面
├── CameraViewModel.swift        # 相机业务逻辑
├── IdentificationPage.swift      # 图片识别页面
├── IdentificationViewModel.swift # 识别业务逻辑
├── WordBookPage.swift           # 单词本详情页面
├── Managers/
│   └── WordBookManager.swift    # 数据管理器
├── Models/
│   ├── WordBook.swift           # 单词本数据模型
│   └── WordModel.swift          # 单词数据模型
├── Data/
│   └── WordBookDataContainer.swift # 数据容器配置
└── Views/
    └── WordBookExampleView.swift # 示例视图
```

## 核心功能展示

### 1. 📸 拍照功能集成

#### CameraPage + CameraViewModel
- **功能**: 完整的相机拍摄界面
- **特性**:
  - 实时预览
  - 相机切换（前置/后置）
  - 闪光灯控制
  - 拍照按钮交互
- **集成**: 调用系统相机 API 和 GLCamera 库

#### 使用示例
```swift
// 打开相机页面
Navigator.present(CameraPage(), from: "main_app")

// CameraViewModel 中的拍照逻辑
func capturePhoto() {
    // 1. 触发相机拍照
    // 2. 处理拍摄结果
    // 3. 跳转到识别页面
    Navigator.present(IdentificationPage(image: capturedImage), from: "camera")
}
```

### 2. 🤖 LLM 调用服务集成

#### IdentificationViewModel
- **功能**: 图片识别和单词提取
- **流程**:
  1. 图片处理和抠图
  2. 上传到 S3 存储
  3. 调用 TemplateAPI.ChatGPT 进行识别
  4. 返回识别结果

#### 核心实现
```swift
private func identifyImageWithLLM(image: UIImage, targetLanguage: String) async throws -> String {
    // 1. 上传图片到S3
    let imageUrl = try await TemplateAPI.S3.upload(data: imageData, fileExtension: "jpg")

    // 2. 构造LLM消息
    let systemMessage = ChatGPTMessage(messageId: 1, role: GPTRole.system, content: "识别指令", imageUrl: nil)
    let imageMessage = ChatGPTMessage(messageId: 2, role: GPTRole.user, content: "", imageUrl: imageUrl)

    // 3. 调用LLM API
    let response = try await TemplateAPI.ChatGPT.llmCompletion(
        [systemMessage, imageMessage],
        configuration: GPTConfig.default,
        responseFormat: nil
    )

    return response.trimmingCharacters(in: .whitespacesAndNewlines)
}
```

### 3. 💾 数据持久化集成

#### SwiftData 数据模型
- **WordBook**: 按天组织的单词本容器
- **WordModel**: 单个单词的完整信息
- **学习算法**: 基于遗忘曲线的复习系统

#### WordBookManager
```swift
class WordBookManager: ObservableObject {
    static let shared = WordBookManager()

    // 获取所有单词本
    func getWordBooks() -> [WordBook]

    // 创建新单词
    func createWord(image: UIImage, targetLanguage: String, word: String) -> WordModel?

    // 获取需要复习的单词
    func getWordsForReview(date: Date) -> [WordModel]

    // 更新学习进度
    func updateWordProgress(_ word: WordModel, masteryLevel: Int)
}
```

#### 学习算法
```swift
// 简化的遗忘曲线算法
private func calculateNextReview(reviewCount: Int) -> Date {
    let intervals = [0, 1, 2, 4, 7, 15] // 天数
    let interval = reviewCount < intervals.count ? intervals[reviewCount] : intervals.last!
    return Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
}
```

### 4. 🗺️ 导航系统集成

#### 页面导航流程
```swift
// 主应用 -> 相机页面
Navigator.present(CameraPage(), from: "main_app")

// 相机页面 -> 识别页面
Navigator.present(IdentificationPage(image: image), from: "camera")

// 识别页面 -> 单词本详情
Navigator.present(WordBookPage(wordBook: wordBook), from: "identification")

// 设置页面导航
Navigator.openSettings("word_book")
```

## 数据模型详解

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
    var masteredWordCount: Int {
        return words.filter { $0.masteryLevel >= 4 }.count
    }
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

## 核心页面详解

### 1. MainAppView (主应用界面)

#### 功能特性
- 显示问候语和今日学习统计
- 大相机拍照按钮（核心功能入口）
- 按日期分组的单词本列表
- 设置页面入口

#### UI 组件
```swift
VStack {
    // 问候语区域
    GreetingSection()

    // 统计信息区域
    StatsSection(wordCount: todayWords, masteredCount: masteredWords)

    // 大拍照按钮
    CameraButton {
        Navigator.present(CameraPage(), from: "main_app")
    }

    // 单词本列表
    WordBookList(wordBooks: wordBooks)
}
```

### 2. CameraPage (拍照界面)

#### 功能特性
- 实时相机预览
- 拍照控制按钮
- 相机切换和闪光灯控制
- 权限检查和错误处理

#### 核心实现
```swift
struct CameraPage: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            // 相机预览
            CameraPreview(session: viewModel.session)

            // 控制按钮
            VStack {
                Spacer()
                HStack {
                    // 闪光灯按钮
                    FlashButton(isOn: $viewModel.isFlashOn)

                    Spacer()

                    // 拍照按钮
                    CameraButton {
                        viewModel.capturePhoto()
                    }

                    Spacer()

                    // 切换相机按钮
                    SwitchCameraButton {
                        viewModel.switchCamera()
                    }
                }
                .padding()
            }
        }
    }
}
```

### 3. IdentificationPage (识别页面)

#### 功能特性
- 拍摄结果预览
- AI 识别进度指示
- 单词提取结果显示
- 保存或重拍选项

#### 处理流程
```swift
struct IdentificationPage: View {
    @StateObject private var viewModel: IdentificationViewModel

    var body: some View {
        VStack {
            // 图片预览区域
            Image(uiImage: viewModel.currentImage ?? originalImage)
                .resizable()
                .aspectRatio(contentMode: .fit)

            // 状态指示器
            StatusIndicator(
                text: viewModel.statusText,
                state: viewModel.currentState
            )

            // 识别结果
            if let word = viewModel.identifiedWord {
                WordResultView(word: word) {
                    viewModel.saveToWordbook()
                }
            }
        }
        .onAppear {
            viewModel.startIdentification()
        }
    }
}
```

### 4. WordBookPage (单词本详情)

#### 功能特性
- 单词本详情展示
- 单词列表管理
- 学习状态查看
- 复习功能入口

#### 核心组件
```swift
struct WordBookPage: View {
    let wordBook: WordBook
    @StateObject private var manager = WordBookManager.shared

    var body: some View {
        VStack {
            // 单词本信息
            WordBookHeader(wordBook: wordBook)

            // 单词列表
            List(wordBook.words, id: \.id) { word in
                WordRowView(word: word) {
                    // 点击单词查看详情
                    Navigator.present(WordDetailView(word: word), from: "word_book")
                }
            }

            // 底部操作按钮
            HStack {
                ReviewButton { /* 开始复习 */ }
                AddWordButton { /* 添加单词 */ }
            }
        }
    }
}
```

## 使用指南

### 基本使用流程
1. **启动应用**: 进入 MainAppView
2. **拍照识别**: 点击相机按钮，拍照并识别单词
3. **查看结果**: 在 IdentificationPage 查看识别结果
4. **保存单词**: 将识别结果保存到单词本
5. **管理学习**: 在 WordBookPage 查看和管理单词

### 自定义配置
```swift
// 修改学习算法参数
extension WordModel {
    private func calculateNextReview() -> Date {
        // 自定义复习间隔算法
        let customIntervals = [1, 3, 7, 14, 30]
        // ...
    }
}

// 自定义识别提示词
private func getIdentificationPrompt(for language: String) -> String {
    return "请识别图片中的主要物体，返回对应的\(language)单词。"
}
```

### 扩展功能
```swift
// 添加新的数据字段
extension WordModel {
    var context: String?        // 单词上下文
    var pronunciation: String?  // 发音
    var exampleSentence: String? // 例句
}

// 添加新的学习模式
enum LearningMode {
    case flashcard
    case quiz
    case spelling
}
```

## 测试建议

### 单元测试
- [ ] WordBookManager 数据操作测试
- [ ] WordModel 学习算法测试
- [ ] 图片处理功能测试
- [ ] SwiftData 持久化测试

### 集成测试
- [ ] 相机功能集成测试
- [ ] LLM 识别流程测试
- [ ] 导航系统集成测试

### UI 测试
- [ ] 拍照流程测试
- [ ] 单词本管理测试
- [ ] 学习功能测试

## 性能优化

### 图片处理优化
- 图片压缩至合适尺寸（320x320）
- 异步处理避免 UI 阻塞
- 内存管理及时释放大图片

### 数据加载优化
- 分页加载单词列表
- 缓存常用查询结果
- 后台同步数据

### LLM 调用优化
- 批量处理减少请求次数
- 缓存识别结果
- 错误重试机制

## 常见问题

### Q: 如何添加新的图片处理效果？
A: 在 IdentificationViewModel 中添加新的处理方法，更新处理流程。

### Q: 如何自定义学习算法？
A: 修改 WordModel 中的复习间隔计算逻辑，或实现新的算法策略。

### Q: 如何处理相机权限？
A: 在 CameraViewModel 中实现权限检查逻辑，提供友好的权限申请界面。

### Q: 如何优化大量单词的加载性能？
A: 实现分页加载、数据缓存和后台同步机制。

---

*WordBook 模块完整展示了四大核心能力的协同工作，是企业级 iOS 开发的最佳实践示例。*