# LLM 调用服务使用指南

## 概述

HackWords 模板通过 `TemplateAPI.ChatGPT` 提供了完整的 LLM 调用服务，支持文本对话、图片识别、会话管理等功能。该服务基于 OpenAI API 构建，提供了简洁易用的 Swift 接口。

## 核心 API 接口

### 1. 会话管理

#### 创建会话
```swift
// 创建新的聊天会话
let sessionId = try await TemplateAPI.ChatGPT.createSession("user_123_session")
```

#### 获取历史消息
```swift
// 获取指定会话的历史消息
let messages = try await TemplateAPI.ChatGPT.fetchMessages(sessionId)
```

#### 保存消息到会话
```swift
// 保存消息到指定会话
let savedMessages = try await TemplateAPI.ChatGPT.saveMessages(messages, toSession: sessionId)
```

### 2. 消息发送

#### 发送消息并获取回复
```swift
// 发送消息并保存最后 n 条到会话
let response = try await TemplateAPI.ChatGPT.sendMessage(
    messages,
    toSession: sessionId,
    configuration: GPTConfig.default,
    messagesToSave: 1  // 保存最后1条消息
)
```

#### 一次性 LLM 调用（不保存到会话）
```swift
// 直接调用 LLM，不保存消息
let response = try await TemplateAPI.ChatGPT.llmCompletion(
    messages,
    configuration: GPTConfig.default,
    responseFormat: nil
)
```

## 数据模型

### ChatGPTMessage
```swift
struct ChatGPTMessage: Codable {
    let messageId: Int64        // 消息ID
    let role: String           // 角色: system, user, assistant
    let content: String?       // 文本内容
    let imageUrl: String?      // 图片URL（可选）
}
```

### GPTConfig
```swift
struct GPTConfig {
    let model: GPTModel        // 模型类型
    let maxTokens: Int         // 最大token数
    let temperature: Float     // 温度参数

    static let `default` = GPTConfig(
        model: .gpt4o_mini,
        maxTokens: 1200,
        temperature: 0.8
    )
}
```

### 预定义模型
```swift
public extension GPTModel {
    static let gpt4o = "gpt-4o"
    static let gpt4o_mini = "gpt-4o-mini"
}
```

### 预定义角色
```swift
public extension GPTRole {
    static let system = "system"
    static let user = "user"
    static let assistant = "assistant"
}
```

## 实际使用示例

### 示例 1：图片识别（来自 IdentificationViewModel）

这是模板中最完整的使用示例，展示了如何进行图片识别：

```swift
private func identifyImageWithLLM(image: UIImage, targetLanguage: String) async throws -> String {
    // 1. 上传图片到S3
    let imageUrl = try await TemplateAPI.S3.upload(data: imageData, fileExtension: "jpg")

    // 2. 构造消息数组
    let systemMessage = ChatGPTMessage(
        messageId: 1,
        role: GPTRole.system,
        content: "你是一个专业的图片识别助手。请识别图片中的主要物体，并返回对应的\(targetLanguage)单词。只需要返回一个单词，不要包含任何其他解释。",
        imageUrl: nil
    )

    let imageMessage = ChatGPTMessage(
        messageId: 2,
        role: GPTRole.user,
        content: "",
        imageUrl: imageUrl
    )

    let textMessage = ChatGPTMessage(
        messageId: 3,
        role: GPTRole.user,
        content: "请识别这张图片中的主要物体，返回对应的\(targetLanguage)单词。",
        imageUrl: nil
    )

    // 3. 调用 LLM API
    let response = try await TemplateAPI.ChatGPT.llmCompletion(
        [systemMessage, imageMessage, textMessage],
        configuration: GPTConfig.default,
        responseFormat: nil
    )

    // 4. 处理响应
    return response.trimmingCharacters(in: .whitespacesAndNewlines)
}
```

### 示例 2：文本对话

```swift
func performTextChat() async throws {
    let sessionId = try await TemplateAPI.ChatGPT.createSession("chat_session_001")

    let userMessage = ChatGPTMessage(
        messageId: 1,
        role: GPTRole.user,
        content: "你好，请介绍一下SwiftUI的特点",
        imageUrl: nil
    )

    let response = try await TemplateAPI.ChatGPT.sendMessage(
        [userMessage],
        toSession: sessionId,
        configuration: GPTConfig.default,
        messagesToSave: 2  // 保存用户消息和AI回复
    )

    // response 包含 [用户消息, AI回复消息]
    if response.count >= 2 {
        let aiResponse = response[1]
        print("AI回复: \(aiResponse.content ?? "")")
    }
}
```

### 示例 3：批量数据处理

```swift
func processBatchData() async throws {
    let prompts = [
        "将以下英文翻译成中文：Hello World",
        "解释什么是机器学习",
        "推荐5本iOS开发书籍"
    ]

    for (index, prompt) in prompts.enumerated() {
        let message = ChatGPTMessage(
            messageId: Int64(index + 1),
            role: GPTRole.user,
            content: prompt,
            imageUrl: nil
        )

        let response = try await TemplateAPI.ChatGPT.llmCompletion(
            [message],
            configuration: GPTConfig(model: .gpt4o_mini, maxTokens: 500, temperature: 0.3),
            responseFormat: nil
        )

        print("问题\(index + 1)答案: \(response)")
    }
}
```

## 最佳实践

### 1. 错误处理
```swift
do {
    let response = try await TemplateAPI.ChatGPT.llmCompletion(messages, configuration: GPTConfig.default, responseFormat: nil)
    // 处理响应
} catch ChatGPTRequestError.networkError {
    // 处理网络错误
    print("网络连接失败")
} catch {
    // 处理其他错误
    print("LLM调用失败: \(error.localizedDescription)")
}
```

### 2. 配置优化
```swift
// 用于 creative writing
let creativeConfig = GPTConfig(model: .gpt4o, maxTokens: 2000, temperature: 0.9)

// 用于 factual responses
let factualConfig = GPTConfig(model: .gpt4o_mini, maxTokens: 800, temperature: 0.1)

// 用于 code generation
let codeConfig = GPTConfig(model: .gpt4o, maxTokens: 1500, temperature: 0.2)
```

### 3. 消息结构设计
```swift
// 系统指令 - 定义AI角色和行为
let systemPrompt = ChatGPTMessage(
    messageId: 1,
    role: GPTRole.system,
    content: "你是一个专业的iOS开发顾问，提供简洁准确的技术建议。",
    imageUrl: nil
)

// 用户查询 - 具体问题
let userQuery = ChatGPTMessage(
    messageId: 2,
    role: GPTRole.user,
    content: "如何在SwiftUI中实现列表的无限滚动？",
    imageUrl: nil
)
```

## 注意事项

1. **图片处理**: 图片需要先上传到S3，然后通过URL传递给LLM
2. **消息顺序**: 消息数组中最后一条消息是当前查询，前面的消息提供上下文
3. **会话管理**: 使用 `messagesToSave` 参数控制哪些消息需要保存到会话历史
4. **Token限制**: 根据模型和配置的 `maxTokens` 限制响应长度
5. **错误处理**: 始终包含适当的错误处理逻辑

## 相关文件位置

- **API定义**: `HackWeek/GPTAPI.swift`
- **API实现**: `HackWeek/TemplateAPI.swift` 中的 `ChatGPTAPI` 协议
- **使用示例**: `HackWeek/Features/WordBook/IdentificationViewModel.swift`
- **S3上传**: 通过 `TemplateAPI.S3.upload()` 方法

这个LLM服务为HackWords模板提供了强大的AI能力，可以用于图片识别、文本对话、数据处理等多种场景。