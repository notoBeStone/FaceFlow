//
//  MeView.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import SwiftData
import GLMP

/// 面部属性数据分组
struct FaceAttributeSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [FaceAttributeItem]
}

/// 面部属性项
struct FaceAttributeItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String?
    let attributeId: String
}

/// 编辑属性数据
struct EditingAttributeData: Identifiable {
    let id = UUID()
    let question: AttributeQuestion
    let currentValue: String?
}

/// Me 页面
struct MeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userAttributes: [UserFaceAttributes]
    
    @State private var showingOnboarding = false
    @State private var editingAttribute: EditingAttributeData?
    
    private var attributes: UserFaceAttributes? {
        userAttributes.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBG
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 面部属性配置
                        if let attributes = attributes {
                            faceAttributesSection(attributes: attributes)
                        } else {
                            emptyProfileSection
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(GLMPLanguage.me_title)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        TemplateAPI.Navigator.openSettings("main")
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.mainColor)
                    }
                }
            }
            .sheet(isPresented: $showingOnboarding) {
                FaceAttributesOnboardingContainer {
                    showingOnboarding = false
                }
            }
            .sheet(item: $editingAttribute) { editData in
                SingleAttributeEditor(
                    question: editData.question,
                    currentValue: editData.currentValue,
                    onSave: { newValue in
                        saveAttribute(attributeId: editData.question.id, value: newValue)
                        editingAttribute = nil
                    },
                    onCancel: {
                        editingAttribute = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Empty Profile Section
    
    private var emptyProfileSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 60))
                    .foregroundColor(.mainColor.opacity(0.6))
                
                Text(GLMPLanguage.me_face_attributes_title)
                    .font(.avenirTitle3Heavy)
                    .foregroundColor(.g9L)
                
                Text(GLMPLanguage.me_empty_profile)
                    .font(.avenirBodyRoman)
                    .foregroundColor(.g6L)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                showingOnboarding = true
            } label: {
                Text(GLMPLanguage.me_complete_profile)
                    .font(.avenirBodyMedium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.mainColor, .mainSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
        }
        .padding(.vertical, 32)
        .background(Color.gwL)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Face Attributes Section
    
    private func faceAttributesSection(attributes: UserFaceAttributes) -> some View {
        VStack(spacing: 16) {
            // Section Header
            Text(GLMPLanguage.me_face_attributes_title)
                .font(.avenirTitle3Heavy)
                .foregroundColor(.g9L)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            // Attribute Groups
            let sections = createAttributeSections(from: attributes)
            ForEach(sections) { section in
                attributeGroupCard(section: section)
            }
        }
    }
    
    private func attributeGroupCard(section: FaceAttributeSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Title
            Text(section.title)
                .font(.avenirBodyHeavy)
                .foregroundColor(.g8L)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            // Attributes List
            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                attributeRow(item: item)
                
                if index < section.items.count - 1 {
                    Divider()
                        .padding(.leading, 20)
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color.gwL)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private func attributeRow(item: FaceAttributeItem) -> some View {
        Button {
            // 获取当前属性值
            let currentValue = getCurrentAttributeValue(attributeId: item.attributeId)
            
            // 根据 attributeId 创建对应的问题
            if let question = createQuestion(for: item.attributeId) {
                editingAttribute = EditingAttributeData(
                    question: question,
                    currentValue: currentValue
                )
            }
        } label: {
            HStack(spacing: 12) {
                Text(item.label)
                    .font(.avenirBodyRoman)
                    .foregroundColor(.g9L)
                
                Spacer()
                
                Text(item.value ?? GLMPLanguage.me_not_set)
                    .font(.avenirBodyRoman)
                    .foregroundColor(item.value != nil ? .g7L : .g5L)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.g5L)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }
    
    // MARK: - Helper Methods
    
    /// 根据属性 ID 创建对应的问题
    private func createQuestion(for attributeId: String) -> AttributeQuestion? {
        switch attributeId {
        case "ageRange": return FaceAttributesQuestionFactory.createAgeRangeQuestion()
        case "faceShape": return FaceAttributesQuestionFactory.createFaceShapeQuestion()
        case "cheekboneProminence": return FaceAttributesQuestionFactory.createCheekboneQuestion()
        case "jawlineType": return FaceAttributesQuestionFactory.createJawlineQuestion()
        case "chinShape": return FaceAttributesQuestionFactory.createChinQuestion()
        case "eyeSize": return FaceAttributesQuestionFactory.createEyeSizeQuestion()
        case "eyeShape": return FaceAttributesQuestionFactory.createEyeShapeQuestion()
        case "eyeDistance": return FaceAttributesQuestionFactory.createEyeDistanceQuestion()
        case "eyebrowShape": return FaceAttributesQuestionFactory.createEyebrowQuestion()
        case "noseLength": return FaceAttributesQuestionFactory.createNoseLengthQuestion()
        case "noseWidth": return FaceAttributesQuestionFactory.createNoseWidthQuestion()
        case "lipsThickness": return FaceAttributesQuestionFactory.createLipsThicknessQuestion()
        case "lipsShape": return FaceAttributesQuestionFactory.createLipsShapeQuestion()
        case "skinType": return FaceAttributesQuestionFactory.createSkinTypeQuestion()
        case "skinTone": return FaceAttributesQuestionFactory.createSkinToneQuestion()
        case "skinBlemishes": return FaceAttributesQuestionFactory.createSkinBlemishesQuestion()
        default: return nil
        }
    }
    
    /// 获取当前属性值
    private func getCurrentAttributeValue(attributeId: String) -> String? {
        guard let attributes = attributes else { return nil }
        
        switch attributeId {
        case "ageRange": return attributes.ageRange
        case "faceShape": return attributes.faceShape
        case "cheekboneProminence": return attributes.cheekboneProminence
        case "jawlineType": return attributes.jawlineType
        case "chinShape": return attributes.chinShape
        case "eyeSize": return attributes.eyeSize
        case "eyeShape": return attributes.eyeShape
        case "eyeDistance": return attributes.eyeDistance
        case "eyebrowShape": return attributes.eyebrowShape
        case "noseLength": return attributes.noseLength
        case "noseWidth": return attributes.noseWidth
        case "lipsThickness": return attributes.lipsThickness
        case "lipsShape": return attributes.lipsShape
        case "skinType": return attributes.skinType
        case "skinTone": return attributes.skinTone
        case "skinBlemishes": return attributes.skinBlemishes
        default: return nil
        }
    }
    
    /// 保存单个属性的更改
    private func saveAttribute(attributeId: String, value: String) {
        guard let attributes = attributes else { return }
        
        switch attributeId {
        case "ageRange": attributes.ageRange = value
        case "faceShape": attributes.faceShape = value
        case "cheekboneProminence": attributes.cheekboneProminence = value
        case "jawlineType": attributes.jawlineType = value
        case "chinShape": attributes.chinShape = value
        case "eyeSize": attributes.eyeSize = value
        case "eyeShape": attributes.eyeShape = value
        case "eyeDistance": attributes.eyeDistance = value
        case "eyebrowShape": attributes.eyebrowShape = value
        case "noseLength": attributes.noseLength = value
        case "noseWidth": attributes.noseWidth = value
        case "lipsThickness": attributes.lipsThickness = value
        case "lipsShape": attributes.lipsShape = value
        case "skinType": attributes.skinType = value
        case "skinTone": attributes.skinTone = value
        case "skinBlemishes": attributes.skinBlemishes = value
        default: break
        }
        
        attributes.updatedAt = Date()
        
        do {
            try modelContext.save()
            print("✅ 成功更新属性 \(attributeId) 为: \(value)")
        } catch {
            print("❌ 保存属性失败: \(error)")
        }
    }
    
    private func createAttributeSections(from attributes: UserFaceAttributes) -> [FaceAttributeSection] {
        return [
            // Face Structure
            FaceAttributeSection(
                title: GLMPLanguage.me_section_face_structure,
                items: [
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_face_shape,
                        value: attributes.faceShape.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "faceShape"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_cheekbone,
                        value: attributes.cheekboneProminence.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "cheekboneProminence"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_jawline,
                        value: attributes.jawlineType.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "jawlineType"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_chin,
                        value: attributes.chinShape.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "chinShape"
                    )
                ]
            ),
            
            // Eye Features
            FaceAttributeSection(
                title: GLMPLanguage.me_section_eye_features,
                items: [
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_eye_size,
                        value: attributes.eyeSize.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "eyeSize"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_eye_shape,
                        value: attributes.eyeShape.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "eyeShape"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_eye_distance,
                        value: attributes.eyeDistance.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "eyeDistance"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_eyebrow,
                        value: attributes.eyebrowShape.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "eyebrowShape"
                    )
                ]
            ),
            
            // Nose & Lips
            FaceAttributeSection(
                title: GLMPLanguage.me_section_nose_lips,
                items: [
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_nose_length,
                        value: attributes.noseLength.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "noseLength"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_nose_width,
                        value: attributes.noseWidth.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "noseWidth"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_lips_thickness,
                        value: attributes.lipsThickness.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "lipsThickness"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_lips_shape,
                        value: attributes.lipsShape.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "lipsShape"
                    )
                ]
            ),
            
            // Skin Profile
            FaceAttributeSection(
                title: GLMPLanguage.me_section_skin_profile,
                items: [
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_skin_type,
                        value: attributes.skinType.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "skinType"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_skin_tone,
                        value: attributes.skinTone.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "skinTone"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_skin_blemishes,
                        value: attributes.skinBlemishes.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "skinBlemishes"
                    ),
                    FaceAttributeItem(
                        label: GLMPLanguage.me_attribute_age_range,
                        value: attributes.ageRange.flatMap { FaceAttributesLocalizedStrings.getOptionTitle(for: $0) },
                        attributeId: "ageRange"
                    )
                ]
            )
        ]
    }
}

#Preview {
    MeView()
        .modelContainer(for: [WordBook.self, WordModel.self, UserFaceAttributes.self])
}

