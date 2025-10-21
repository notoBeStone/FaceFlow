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
    @Published var currentStageIndex: Int = 0
    @Published var currentQuestionIndex: Int = 0
    @Published var isShowingEncouragement: Bool = false
    @Published var selectedAnswers: [String: String] = [:] // questionId: value
    
    // 三个阶段的问题 - 使用本地化文案
    lazy var stages: [OnboardingStage] = {
        let stage1Info = FaceAttributesLocalizedStrings.getStageInfo(for: 0)
        let stage2Info = FaceAttributesLocalizedStrings.getStageInfo(for: 1)
        let stage3Info = FaceAttributesLocalizedStrings.getStageInfo(for: 2)
        
        return [
            // 第一阶段：了解脸型
            OnboardingStage(
                id: 0,
                title: stage1Info.title,
                subtitle: stage1Info.subtitle,
                emoji: stage1Info.emoji,
                questions: FaceAttributesQuestionFactory.createStage1Questions()
            ),
            // 第二阶段：了解五官
            OnboardingStage(
                id: 1,
                title: stage2Info.title,
                subtitle: stage2Info.subtitle,
                emoji: stage2Info.emoji,
                questions: FaceAttributesQuestionFactory.createStage2Questions()
            ),
            // 第三阶段：了解肤质
            OnboardingStage(
                id: 2,
                title: stage3Info.title,
                subtitle: stage3Info.subtitle,
                emoji: stage3Info.emoji,
                questions: FaceAttributesQuestionFactory.createStage3Questions()
            )
        ]
    }()
    
    // MARK: - Computed Properties
    
    var currentStage: OnboardingStage {
        stages[currentStageIndex]
    }
    
    var currentQuestion: AttributeQuestion? {
        guard currentQuestionIndex < currentStage.questions.count else { return nil }
        return currentStage.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        let totalQuestions = stages.reduce(0) { $0 + $1.questions.count }
        let completedQuestions = stages.prefix(currentStageIndex).reduce(0) { $0 + $1.questions.count } + currentQuestionIndex
        return Double(completedQuestions) / Double(totalQuestions)
    }
    
    var isLastStage: Bool {
        currentStageIndex == stages.count - 1
    }
    
    var isLastQuestionInStage: Bool {
        currentQuestionIndex == currentStage.questions.count - 1
    }
    
    // MARK: - Actions
    
    func selectAnswer(questionId: String, value: String) {
        selectedAnswers[questionId] = value
        moveToNext()
    }
    
    func moveToNext() {
        if isLastQuestionInStage {
            // 当前阶段的最后一个问题
            if isLastStage {
                // 是最后一个阶段，完成流程
                completeFlow()
            } else {
                // 显示鼓励页面
                isShowingEncouragement = true
            }
        } else {
            // 移动到下一个问题
            currentQuestionIndex += 1
        }
    }
    
    func moveToNextStage() {
        currentStageIndex += 1
        currentQuestionIndex = 0
        isShowingEncouragement = false
    }
    
    func completeFlow() {
        // 流程完成后的处理
        print("✅ 面部属性收集完成: \(selectedAnswers)")
    }
    
    func skipQuestion() {
        moveToNext()
    }
}
