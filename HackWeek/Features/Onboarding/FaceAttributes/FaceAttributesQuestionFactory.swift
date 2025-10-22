//
//  FaceAttributesQuestionFactory.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import Foundation

/// 面部属性问题工厂 - 使用本地化文案创建问题
struct FaceAttributesQuestionFactory {
    
    // MARK: - Create Questions
    
    static func createAgeRangeQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .ageRange)
        return AttributeQuestion(
            id: "ageRange",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "under18", title: GLMPLanguage.faceAttributes_age_under18, imageName: "age_under18", value: AgeRange.under18.rawValue),
                AttributeOption(id: "19to25", title: GLMPLanguage.faceAttributes_age_19to25, imageName: "age_19_25", value: AgeRange.age19to25.rawValue),
                AttributeOption(id: "26to35", title: GLMPLanguage.faceAttributes_age_26to35, imageName: "age_26_35", value: AgeRange.age26to35.rawValue),
                AttributeOption(id: "36to45", title: GLMPLanguage.faceAttributes_age_36to45, imageName: "age_36_45", value: AgeRange.age36to45.rawValue),
                AttributeOption(id: "over45", title: GLMPLanguage.faceAttributes_age_over45, imageName: "age_over45", value: AgeRange.over45.rawValue)
            ],
            attributeType: .ageRange
        )
    }
    
    static func createFaceShapeQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .faceShape)
        return AttributeQuestion(
            id: "faceShape",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "round", title: GLMPLanguage.faceAttributes_faceShape_round, imageName: "face_round", value: FaceShape.round.rawValue),
                AttributeOption(id: "oval", title: GLMPLanguage.faceAttributes_faceShape_oval, imageName: "face_oval", value: FaceShape.oval.rawValue),
                AttributeOption(id: "square", title: GLMPLanguage.faceAttributes_faceShape_square, imageName: "face_square", value: FaceShape.square.rawValue),
                AttributeOption(id: "oblong", title: GLMPLanguage.faceAttributes_faceShape_oblong, imageName: "face_oblong", value: FaceShape.oblong.rawValue),
                AttributeOption(id: "heart", title: GLMPLanguage.faceAttributes_faceShape_heart, imageName: "face_heart", value: FaceShape.heart.rawValue),
                AttributeOption(id: "invertedTriangle", title: GLMPLanguage.faceAttributes_faceShape_invertedTriangle, imageName: "face_inverted_triangle", value: FaceShape.invertedTriangle.rawValue)
            ],
            attributeType: .faceShape
        )
    }
    
    static func createCheekboneQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .cheekboneProminence)
        return AttributeQuestion(
            id: "cheekboneProminence",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "high", title: GLMPLanguage.faceAttributes_cheekbone_high, imageName: "cheekbone_high", value: CheekboneProminence.high.rawValue),
                AttributeOption(id: "normal", title: GLMPLanguage.faceAttributes_cheekbone_normal, imageName: "cheekbone_normal", value: CheekboneProminence.normal.rawValue),
                AttributeOption(id: "low", title: GLMPLanguage.faceAttributes_cheekbone_low, imageName: "cheekbone_low", value: CheekboneProminence.low.rawValue)
            ],
            attributeType: .cheekboneProminence
        )
    }
    
    static func createJawlineQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .jawlineType)
        return AttributeQuestion(
            id: "jawlineType",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "round", title: GLMPLanguage.faceAttributes_jawline_round, imageName: "jawline_round", value: JawlineType.round.rawValue),
                AttributeOption(id: "sharp", title: GLMPLanguage.faceAttributes_jawline_sharp, imageName: "jawline_sharp", value: JawlineType.sharp.rawValue),
                AttributeOption(id: "square", title: GLMPLanguage.faceAttributes_jawline_square, imageName: "jawline_square", value: JawlineType.square.rawValue),
                AttributeOption(id: "defined", title: GLMPLanguage.faceAttributes_jawline_defined, imageName: "jawline_defined", value: JawlineType.defined.rawValue)
            ],
            attributeType: .jawlineType
        )
    }
    
    static func createChinQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .chinShape)
        return AttributeQuestion(
            id: "chinShape",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "pointed", title: GLMPLanguage.faceAttributes_chin_pointed, imageName: "chin_pointed", value: ChinShape.pointed.rawValue),
                AttributeOption(id: "round", title: GLMPLanguage.faceAttributes_chin_round, imageName: "chin_round", value: ChinShape.round.rawValue),
                AttributeOption(id: "wide", title: GLMPLanguage.faceAttributes_chin_wide, imageName: "chin_wide", value: ChinShape.wide.rawValue)
            ],
            attributeType: .chinShape
        )
    }
    
    // MARK: - Eye Questions
    
    static func createEyeSizeQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .eyeSize)
        return AttributeQuestion(
            id: "eyeSize",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "small", title: GLMPLanguage.faceAttributes_eyeSize_small, imageName: "eye_size_small", value: EyeSize.small.rawValue),
                AttributeOption(id: "normal", title: GLMPLanguage.faceAttributes_eyeSize_normal, imageName: "eye_size_normal", value: EyeSize.normal.rawValue),
                AttributeOption(id: "large", title: GLMPLanguage.faceAttributes_eyeSize_large, imageName: "eye_size_large", value: EyeSize.large.rawValue)
            ],
            attributeType: .eyeSize
        )
    }
    
    static func createEyeShapeQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .eyeShape)
        return AttributeQuestion(
            id: "eyeShape",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "monolid", title: GLMPLanguage.faceAttributes_eyeShape_monolid, imageName: "eye_shape_monolid", value: EyeShape.monolid.rawValue),
                AttributeOption(id: "doubleLid", title: GLMPLanguage.faceAttributes_eyeShape_doubleLid, imageName: "eye_shape_double", value: EyeShape.doubleLid.rawValue),
                AttributeOption(id: "innerDouble", title: GLMPLanguage.faceAttributes_eyeShape_innerDouble, imageName: "eye_shape_inner", value: EyeShape.innerDouble.rawValue),
                AttributeOption(id: "puffy", title: GLMPLanguage.faceAttributes_eyeShape_puffy, imageName: "eye_shape_puffy", value: EyeShape.puffy.rawValue)
            ],
            attributeType: .eyeShape
        )
    }
    
    static func createEyeDistanceQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .eyeDistance)
        return AttributeQuestion(
            id: "eyeDistance",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "wide", title: GLMPLanguage.faceAttributes_eyeDistance_wide, imageName: "eye_distance_wide", value: EyeDistance.wide.rawValue),
                AttributeOption(id: "normal", title: GLMPLanguage.faceAttributes_eyeDistance_normal, imageName: "eye_distance_normal", value: EyeDistance.normal.rawValue),
                AttributeOption(id: "narrow", title: GLMPLanguage.faceAttributes_eyeDistance_narrow, imageName: "eye_distance_narrow", value: EyeDistance.narrow.rawValue)
            ],
            attributeType: .eyeDistance
        )
    }
    
    static func createEyebrowQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .eyebrowShape)
        return AttributeQuestion(
            id: "eyebrowShape",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "straight", title: GLMPLanguage.faceAttributes_eyebrow_straight, imageName: "eyebrow_straight", value: EyebrowShape.straight.rawValue),
                AttributeOption(id: "curved", title: GLMPLanguage.faceAttributes_eyebrow_curved, imageName: "eyebrow_curved", value: EyebrowShape.curved.rawValue),
                AttributeOption(id: "arched", title: GLMPLanguage.faceAttributes_eyebrow_arched, imageName: "eyebrow_arched", value: EyebrowShape.arched.rawValue),
                AttributeOption(id: "angular", title: GLMPLanguage.faceAttributes_eyebrow_angular, imageName: "eyebrow_angular", value: EyebrowShape.angular.rawValue)
            ],
            attributeType: .eyebrowShape
        )
    }
    
    // MARK: - Nose Questions
    
    static func createNoseLengthQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .noseLength)
        return AttributeQuestion(
            id: "noseLength",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "short", title: GLMPLanguage.faceAttributes_noseLength_short, imageName: "nose_length_short", value: NoseLength.short.rawValue),
                AttributeOption(id: "normal", title: GLMPLanguage.faceAttributes_noseLength_normal, imageName: "nose_length_normal", value: NoseLength.normal.rawValue),
                AttributeOption(id: "long", title: GLMPLanguage.faceAttributes_noseLength_long, imageName: "nose_length_long", value: NoseLength.long.rawValue)
            ],
            attributeType: .noseLength
        )
    }
    
    static func createNoseWidthQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .noseWidth)
        return AttributeQuestion(
            id: "noseWidth",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "narrow", title: GLMPLanguage.faceAttributes_noseWidth_narrow, imageName: "nose_width_narrow", value: NoseWidth.narrow.rawValue),
                AttributeOption(id: "normal", title: GLMPLanguage.faceAttributes_noseWidth_normal, imageName: "nose_width_normal", value: NoseWidth.normal.rawValue),
                AttributeOption(id: "wide", title: GLMPLanguage.faceAttributes_noseWidth_wide, imageName: "nose_width_wide", value: NoseWidth.wide.rawValue)
            ],
            attributeType: .noseWidth
        )
    }
    
    // MARK: - Lips Questions
    
    static func createLipsThicknessQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .lipsThickness)
        return AttributeQuestion(
            id: "lipsThickness",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "thin", title: GLMPLanguage.faceAttributes_lipsThickness_thin, imageName: "lips_thickness_thin", value: LipsThickness.thin.rawValue),
                AttributeOption(id: "medium", title: GLMPLanguage.faceAttributes_lipsThickness_medium, imageName: "lips_thickness_medium", value: LipsThickness.medium.rawValue),
                AttributeOption(id: "thick", title: GLMPLanguage.faceAttributes_lipsThickness_thick, imageName: "lips_thickness_thick", value: LipsThickness.thick.rawValue)
            ],
            attributeType: .lipsThickness
        )
    }
    
    static func createLipsShapeQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .lipsShape)
        return AttributeQuestion(
            id: "lipsShape",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "topHeavy", title: GLMPLanguage.faceAttributes_lipsShape_topHeavy, imageName: "lips_shape_top", value: LipsShape.topHeavy.rawValue),
                AttributeOption(id: "bottomHeavy", title: GLMPLanguage.faceAttributes_lipsShape_bottomHeavy, imageName: "lips_shape_bottom", value: LipsShape.bottomHeavy.rawValue),
                AttributeOption(id: "balanced", title: GLMPLanguage.faceAttributes_lipsShape_balanced, imageName: "lips_shape_balanced", value: LipsShape.balanced.rawValue)
            ],
            attributeType: .lipsShape
        )
    }
    
    // MARK: - Skin Questions
    
    static func createSkinTypeQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .skinType)
        return AttributeQuestion(
            id: "skinType",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "dry", title: GLMPLanguage.faceAttributes_skinType_dry, imageName: "skin_type_dry", value: SkinType.dry.rawValue),
                AttributeOption(id: "oily", title: GLMPLanguage.faceAttributes_skinType_oily, imageName: "skin_type_oily", value: SkinType.oily.rawValue),
                AttributeOption(id: "normal", title: GLMPLanguage.faceAttributes_skinType_normal, imageName: "skin_type_normal", value: SkinType.normal.rawValue),
                AttributeOption(id: "combination", title: GLMPLanguage.faceAttributes_skinType_combination, imageName: "skin_type_combination", value: SkinType.combination.rawValue),
                AttributeOption(id: "sensitive", title: GLMPLanguage.faceAttributes_skinType_sensitive, imageName: "skin_type_sensitive", value: SkinType.sensitive.rawValue)
            ],
            attributeType: .skinType
        )
    }
    
    static func createSkinToneQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .skinTone)
        return AttributeQuestion(
            id: "skinTone",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "light", title: GLMPLanguage.faceAttributes_skinTone_light, imageName: "skin_tone_light", value: SkinTone.light.rawValue),
                AttributeOption(id: "medium", title: GLMPLanguage.faceAttributes_skinTone_medium, imageName: "skin_tone_medium", value: SkinTone.medium.rawValue),
                AttributeOption(id: "golden", title: GLMPLanguage.faceAttributes_skinTone_golden, imageName: "skin_tone_golden", value: SkinTone.golden.rawValue),
                AttributeOption(id: "dark", title: GLMPLanguage.faceAttributes_skinTone_dark, imageName: "skin_tone_dark", value: SkinTone.dark.rawValue)
            ],
            attributeType: .skinTone
        )
    }
    
    static func createSkinBlemishesQuestion() -> AttributeQuestion {
        let (question, subtitle) = FaceAttributesLocalizedStrings.getQuestionTitle(for: .skinBlemishes)
        return AttributeQuestion(
            id: "skinBlemishes",
            question: question,
            subtitle: subtitle,
            options: [
                AttributeOption(id: "noneOrFew", title: GLMPLanguage.faceAttributes_skinBlemishes_noneOrFew, imageName: "skin_blemishes_none", value: SkinBlemishes.noneOrFew.rawValue),
                AttributeOption(id: "moderate", title: GLMPLanguage.faceAttributes_skinBlemishes_moderate, imageName: "skin_blemishes_moderate", value: SkinBlemishes.moderate.rawValue),
                AttributeOption(id: "many", title: GLMPLanguage.faceAttributes_skinBlemishes_many, imageName: "skin_blemishes_many", value: SkinBlemishes.many.rawValue)
            ],
            attributeType: .skinBlemishes
        )
    }
    
    // MARK: - Create All Stage Questions
    
    static func createStage1Questions() -> [AttributeQuestion] {
        return [
            createAgeRangeQuestion(),
            createFaceShapeQuestion(),
            createCheekboneQuestion(),
            createJawlineQuestion(),
            createChinQuestion()
        ]
    }
    
    static func createStage2Questions() -> [AttributeQuestion] {
        return [
            createEyeSizeQuestion(),
            createEyeShapeQuestion(),
            createEyeDistanceQuestion(),
            createEyebrowQuestion(),
            createNoseLengthQuestion(),
            createNoseWidthQuestion(),
            createLipsThicknessQuestion(),
            createLipsShapeQuestion()
        ]
    }
    
    static func createStage3Questions() -> [AttributeQuestion] {
        return [
            createSkinTypeQuestion(),
            createSkinToneQuestion(),
            createSkinBlemishesQuestion()
        ]
    }
}

