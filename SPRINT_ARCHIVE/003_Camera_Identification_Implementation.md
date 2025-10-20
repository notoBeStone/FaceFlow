# Sprint 003: 拍照识别功能实现

## 迭代目标
实现单词本模块中的拍照功能，包括：相机页、识别页。作为两个独立通用的页面使用，不关心业务上下文。

## 功能实现

### 1. 相机页实现 (CameraPage.swift)

**主要功能：**
- 使用系统原生相机，通过 present 方式展现
- 支持相机权限请求和处理
- 拍摄完成后自动跳转到识别页
- 支持权限被拒绝时引导用户到设置页面

**技术实现：**
- 使用 UIImagePickerController 封装成 SwiftUI 可用的组件
- 通过 AVFoundation 检查相机权限
- 使用 TemplateAPI.Navigator.present() 模态展现相机页面
- 使用 TemplateAPI.Navigator.push() 跳转到识别页

**文件结构：**
```
Features/WordBook/
├── CameraPage.swift      # 相机页UI
├── CameraViewModel.swift # 相机页业务逻辑
```

### 2. 识别页实现 (IdentificationPage.swift)

**主要功能：**
- 接收相机页传递的图片，通过 push 方式进入页面
- UI 结构：纵向布局，上 2/3 展示照片处理，下 1/3 展示状态文案
- 支持三种识别状态：
  - 初始态：展现完整图片，文案为 "Processing"
  - 识别态：经过抠图 API 调用，展现主要目标物体，文案为 "Identifying"
  - 完成态：从 LLM API 获得图片对应的单词，文案展示为对应的单词

**技术实现：**
- 使用 VisionKit 进行主体分割抠图
- 集成 TemplateAPI.ChatGPT 进行图片识别
- 支持根据用户目标学习语言进行识别
- 异步处理流程，状态机管理识别过程

**文件结构：**
```
Features/WordBook/
├── IdentificationPage.swift      # 识别页UI
├── IdentificationViewModel.swift # 识别页业务逻辑
```

### 3. 主应用界面 (MainAppView.swift)

**主要功能：**
- 提供测试按钮来验证整个拍照识别流程
- 简洁的主界面布局，为后续功能预留位置

**技术实现：**
- 使用 TemplateAPI.Navigator.present() 展现相机页
- 遵循 GLSwiftUIPageTrackable 协议进行页面追踪

### 4. 核心技术集成

#### VisionKit 抠图实现
```swift
// 使用 VNGenerateForegroundInstanceMaskRequest 进行主体分割
let request = VNGenerateForegroundInstanceMaskRequest { request, error in
    // 处理抠图结果
}

// 创建带透明度通道的图片
let maskedImage = try self.createMaskedImage(from: result, originalImage: cgImage)
```

#### LLM API 集成
```swift
// 构造识别prompt
let systemMessage = ChatGPTMessage(
    messageId: 1,
    role: GPTRole.system,
    content: "你是一个专业的图片识别助手。请识别图片中的主要物体，并返回对应的\(targetLanguage)单词。只需要返回一个单词，不要包含任何其他解释。",
    imageUrl: nil
)

// 调用TemplateAPI.ChatGPT接口
let response = try await TemplateAPI.ChatGPT.llmCompletion(
    [systemMessage, userMessage],
    configuration: GPTConfig.default,
    responseFormat: nil
)
```

## 编译验证
- ✅ 使用 xcodebuild 成功编译项目
- ✅ 目标模拟器：iPhone 17
- ✅ 解决了 Navigator 命名冲突问题，直接使用 TemplateAPI.Navigator

## 使用流程
1. 用户在主应用界面点击"测试相机功能"按钮
2. 相机页通过 present 方式展现
3. 用户拍摄照片后，自动跳转到识别页
4. 识别页显示 Processing → Identifying → 最终识别的单词
5. 用户可以选择保存到单词本或继续拍照

## 文件清单
- `Features/WordBook/CameraPage.swift` - 相机页面UI实现
- `Features/WordBook/CameraViewModel.swift` - 相机页面业务逻辑
- `Features/WordBook/IdentificationPage.swift` - 识别页面UI实现
- `Features/WordBook/IdentificationViewModel.swift` - 识别页面业务逻辑
- `Features/WordBook/MainAppView.swift` - 主应用测试界面
- `Features/Onboarding/OnboardingRootView.swift` - 更新根视图以显示主应用界面

## 下一步计划
实现单词本模块的单词存储和管理功能，包括：
- 单词数据模型设计
- 本地数据存储实现
- 单词列表页面开发
- 单词详情页面开发

## 已知问题
- 保存到单词本功能暂未实现（标记为TODO）
- LLM API 在某些设备上可能需要网络连接
- VisionKit 抠图功能在某些旧设备上可能不支持