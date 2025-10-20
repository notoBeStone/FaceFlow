//
//  ChatGPTImp.swift
//  SupplementID
//
//  Created by stephenwzl on 2025/6/11.
//
import GLMP
import AppModels

extension ChatGPTAPI {
    static func createSession(_ sessionIdentifier: String) async throws -> Int64 {
        let request = ChatbotCreateSessionRequest(sessionType: sessionIdentifier)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw error
        }
        guard let data = res.data else {
            throw ChatGPTRequestError.networkError
        }
        return data.sessionId
    }

    static func fetchMessages(_ sessionId: Int64) async throws -> [ChatGPTMessage] {
        let request = ChatbotFindMessageListRequest(sessionId: sessionId, orderBy: .asc, languageCode: GLMPAppUtil.languageCode, countryCode: GLMPAppUtil.countryCode)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw error
        }
        guard let data = res.data else {
            throw ChatGPTRequestError.networkError
        }
        let messageList = data.messageList
        return messageList.map { model in
            ChatGPTMessage.from(model)
        }
    }
    
    static func saveMessages(_ messages: [ChatGPTMessage], toSession: Int64) async throws -> [ChatGPTMessage] {
        return try await saveMessages(messages: messages, sessionId: toSession)
    }
    
    static func sendMessage(_ message: [ChatGPTMessage], toSession: Int64, configuration: GPTConfig? = .default, messagesToSave: Int = 1) async throws -> [ChatGPTMessage] {
        let messages = message.map { $0.toMessage() }
        let config = configuration ?? .default
        let roles = message.map { MessageFrom.from($0.role) }
        let request = ChatbotSendMessageRequest(sessionId: toSession, languageCode: GLMPAppUtil.languageCode, countryCode: GLMPAppUtil.countryCode, recordMessage: false, messageContents: messages, roles: roles.map { $0.rawValue }, chatArgs: .init(model: config.model, maxTokens: config.maxTokens, temperature: Double(config.temperature)), responseFormat: nil)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw error
        }
        let data = res.data?.replyMessageList ?? []
        if data.isEmpty {
            throw ChatGPTRequestError.networkError
        }
        let results = data.map { ChatGPTMessage.from($0) }
        if messagesToSave > 0 {
            var toSaveMessage = Array(message.suffix(messagesToSave))
            toSaveMessage.append(contentsOf: results)
            return try await saveMessages(messages: toSaveMessage, sessionId: toSession)
        }
        return results
    }

    static func llmCompletion(_ messages: [ChatGPTMessage], configuration: GPTConfig?, responseFormat: String?) async throws -> String {
        let session = try await createSession("llm_completion")
        let config = configuration ?? .default
        let request = ChatbotSendMessageRequest(sessionId: session, languageCode: GLMPAppUtil.languageCode, countryCode: GLMPAppUtil.countryCode, messageContents: messages.map { $0.toMessage() }, roles: messages.map { MessageFrom.from($0.role).rawValue }, chatArgs: .init(model: config.model, maxTokens: config.maxTokens, temperature: Double(config.temperature)), responseFormat: responseFormat)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw error
        }
        guard let data = res.data else {
            throw ChatGPTRequestError.networkError
        }
        return data.replyMessageList.first?.messageContent.text ?? ""
    }
    
    @discardableResult
    private static func saveMessages(messages: [ChatGPTMessage], sessionId: Int64) async throws -> [ChatGPTMessage] {
        let toAdd = messages.map { msg in
            AddMessageParamModel(sessionId: sessionId, from: .from(msg.role), messageContent: msg.toMessage())
        }
        let request = ChatbotAddMessagesRequest(languageCode: GLMPAppUtil.languageCode, countryCode: GLMPAppUtil.countryCode, addMessageParams: toAdd)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw error
        }
        if let addedMessageList = res.data?.addedMessageList {
            return addedMessageList.map { ChatGPTMessage.from($0)}
        }
        throw ChatGPTRequestError.networkError
    }
}

extension ChatGPTMessage {
    func toMessage() -> MessageContentModel {
        let isImgMessage = imageUrl != nil
        if isImgMessage {
            let imageModel = ImageMessageContentModel(url: imageUrl!, itemId: 0, itemType: "image")
            return MessageContentModel(messageType: .image, text: imageModel.jsonString ?? "")
        }
        return MessageContentModel(messageType: .text, text: content ?? "")
    }
    
    static func from(_ messageModel: MessageModel) -> Self {
        let isImgMessage = messageModel.messageContent.messageType == .image
        let content: String? = isImgMessage ? nil : messageModel.messageContent.text
        var imageModel: ImageMessageContentModel?
        if isImgMessage {
            imageModel = ImageMessageContentModel(jsonString: messageModel.messageContent.text)
        }
        return .init(messageId: messageModel.messageId ?? Int64(Date().timeIntervalSince1970) * 1000,
                     role: messageModel.from.role,
                     content: content,
                     imageUrl: imageModel?.url)
    }
}

extension MessageFrom {
    var role: String {
        switch self {
            case .unknown:
                return "unknown"
            case .user:
                return "user"
            case .chatBot:
                return "assistant"
            case .system:
                return "system"
        }
    }

    static func from(_ role: String) -> MessageFrom {
        switch role {
            case "user":
                return .user
            case "assistant":
                return .chatBot
            case "system":
                return .system
            default:
                return .unknown
        }
    }
}
