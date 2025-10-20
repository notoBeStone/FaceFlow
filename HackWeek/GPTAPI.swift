//
//  GPTAPI.swift
//  SupplementID
//
//  Created by stephenwzl on 2025/6/11.
//

import Foundation


typealias GPTModel = String
public extension GPTModel {
    static let gpt4o = "gpt-4o"
    static let gpt4o_mini = "gpt-4o-mini"
}

typealias GPTRole = String
public extension GPTRole {
    static let system = "system"
    static let user = "user"
    static let assistant = "assistant"
}

struct GPTConfig {
    let model: GPTModel
    let maxTokens: Int
    let temperature: Float
    
    static let `default` = GPTConfig(model: .gpt4o_mini, maxTokens: 1200, temperature: 0.8)
}

struct ChatGPTMessage: Codable {
    let messageId: Int64
    /// 角色: system, user, assistant
    let role: String
    /// 消息内容, 如果是图片消息，content 为空，imageUrl 为图片URL
    let content: String?
    /// 图片URL, 如果是图片消息，imageUrl 为图片URL，content 为空
    let imageUrl: String?
    
    init(messageId: Int64, role: String, content: String?, imageUrl: String?) {
        self.messageId = messageId
        self.role = role
        self.content = content
        self.imageUrl = imageUrl
    }
}

enum ChatGPTRequestError: Error {
    case networkError
    case unknownError
}

protocol ChatGPTAPI {
    /// 创建 chat session，所有的聊天消息都是基于 session 保存的
    /// - Parameters:
    ///   - sessionIdentifier: 会话标识符
    /// - Returns: 会话ID
    static func createSession(_ sessionIdentifier: String) async throws -> Int64
    
    static func fetchMessages(_ sessionId: Int64) async throws -> [ChatGPTMessage]
    
    static func saveMessages(_ messages: [ChatGPTMessage], toSession: Int64) async throws -> [ChatGPTMessage]
    
    /// 发送消息，并且指定保存最后 n 条到 session。不保存的消息无法通过 session获取
    /// - Parameters:
    ///   - message: 消息内容, 与 openai sdk 逻辑一致，携带的历史消息决定了记忆内容，最新一条为当前消息, 通过参数指定自动保存最后 n 条消息
    ///   - toSession: 会话ID
    ///   - configuration: 配置，如果为空，则使用默认配置
    ///   - messagesToSave: 保存的消息数量, 一般是 1，取决于新增了几条新消息，规则是后 n 条消息需要保存，如果为 0，则不保存消息
    /// - Returns: 消息数组，第一条是发送的消息，第二条是返回的消息
    static func sendMessage(_ message: [ChatGPTMessage], toSession: Int64, configuration: GPTConfig?, messagesToSave: Int) async throws -> [ChatGPTMessage]
    
    /// 调用 llm 接口，不保存消息, 可以作为数据生成接口使用
    /// - Parameters:
    ///   - messages: 消息内容, 与 openai sdk 逻辑一致，携带的历史消息决定了记忆内容，最新一条为当前消息
    ///   - configuration: 配置，如果为空，则使用默认配置
    ///   - responseFormat: 响应格式，如果为空，则为文本格式
    /// - Returns: 返回的消息文本
    static func llmCompletion(_ messages: [ChatGPTMessage], configuration: GPTConfig?, responseFormat: String?) async throws -> String
}
