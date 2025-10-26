//
//  FaceAttributesOnboardingFlow.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import Foundation
import SwiftUI

/// 面部属性问题定义
struct AttributeQuestion: Identifiable {
    let id: String
    let question: String           // 问题标题
    let subtitle: String?          // 副标题说明
    let options: [AttributeOption] // 选项列表
    let attributeType: AttributeType
    
    enum AttributeType {
        case faceShape
        case cheekboneProminence
        case jawlineType
        case chinShape
        case eyeSize
        case eyeShape
        case eyeDistance
        case eyebrowShape
        case noseLength
        case noseWidth
        case lipsThickness
        case lipsShape
        case skinType
        case skinTone
        case skinBlemishes
        case ageRange
    }
}

/// 选项定义
struct AttributeOption: Identifiable {
    let id: String
    let title: String              // 选项标题
    let imageName: String          // 图片资源名称
    let value: String              // 对应的枚举值
}

/// 阶段定义
struct OnboardingStage: Identifiable {
    let id: Int
    let title: String              // 阶段标题
    let subtitle: String           // 阶段副标题
    let emoji: String              // 阶段图标
    let questions: [AttributeQuestion]
}

// MARK: - Onboarding Flow Manager

class FaceAttributesOnboardingFlow: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var isCompleted: Bool = false
    @Published var selectedAnswers: [String: String] = [:] // questionId: value
    
    // 简化版：只有两个问题（年龄和肤质）
    lazy var questions: [AttributeQuestion] = {
        return FaceAttributesQuestionFactory.createSimplifiedQuestions()
    }()
    
    // MARK: - Computed Properties
    
    var currentQuestion: AttributeQuestion? {
        // 如果已完成，返回 nil 以显示完成页面
        guard !isCompleted else { return nil }
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    // MARK: - Actions
    
    func selectAnswer(questionId: String, value: String) {
        selectedAnswers[questionId] = value
        moveToNext()
    }
    
    func moveToNext() {
        if isLastQuestion {
            // 最后一个问题，完成流程
            completeFlow()
        } else {
            // 移动到下一个问题
            currentQuestionIndex += 1
        }
    }
    
    func completeFlow() {
        // 标记问卷流程为已完成
        isCompleted = true
        
        // 打印完成信息
        debugPrint("🎉 Face Attributes Onboarding 完成！")
        debugPrint("📊 用户选择的答案: \(selectedAnswers)")
        debugPrint("✅ 总共回答了 \(selectedAnswers.count) 个问题")
    }
    
    func skipQuestion() {
        moveToNext()
    }
}

