//
//  FaceAttributesLocalizedStrings.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import Foundation

/// 面部属性本地化文案辅助类
struct FaceAttributesLocalizedStrings {
    
    // MARK: - Stage Information
    
    static func getStageInfo(for stageId: Int) -> (title: String, subtitle: String, emoji: String) {
        switch stageId {
        case 0:
            return (
                GLMPLanguage.faceAttributes_stage1_title,
                GLMPLanguage.faceAttributes_stage1_subtitle,
                GLMPLanguage.faceAttributes_stage1_emoji
            )
        case 1:
            return (
                GLMPLanguage.faceAttributes_stage2_title,
                GLMPLanguage.faceAttributes_stage2_subtitle,
                GLMPLanguage.faceAttributes_stage2_emoji
            )
        case 2:
            return (
                GLMPLanguage.faceAttributes_stage3_title,
                GLMPLanguage.faceAttributes_stage3_subtitle,
                GLMPLanguage.faceAttributes_stage3_emoji
            )
        default:
            return ("", "", "")
        }
    }
    
    // MARK: - Question Titles
    
    static func getQuestionTitle(for attributeType: AttributeQuestion.AttributeType) -> (question: String, subtitle: String?) {
        switch attributeType {
        case .ageRange:
            return (GLMPLanguage.faceAttributes_question_ageRange, GLMPLanguage.faceAttributes_question_ageRange_subtitle)
        case .faceShape:
            return (GLMPLanguage.faceAttributes_question_faceShape, GLMPLanguage.faceAttributes_question_faceShape_subtitle)
        case .cheekboneProminence:
            return (GLMPLanguage.faceAttributes_question_cheekbone, GLMPLanguage.faceAttributes_question_cheekbone_subtitle)
        case .jawlineType:
            return (GLMPLanguage.faceAttributes_question_jawline, GLMPLanguage.faceAttributes_question_jawline_subtitle)
        case .chinShape:
            return (GLMPLanguage.faceAttributes_question_chin, GLMPLanguage.faceAttributes_question_chin_subtitle)
        case .eyeSize:
            return (GLMPLanguage.faceAttributes_question_eyeSize, nil)
        case .eyeShape:
            return (GLMPLanguage.faceAttributes_question_eyeShape, nil)
        case .eyeDistance:
            return (GLMPLanguage.faceAttributes_question_eyeDistance, GLMPLanguage.faceAttributes_question_eyeDistance_subtitle)
        case .eyebrowShape:
            return (GLMPLanguage.faceAttributes_question_eyebrow, nil)
        case .noseLength:
            return (GLMPLanguage.faceAttributes_question_noseLength, nil)
        case .noseWidth:
            return (GLMPLanguage.faceAttributes_question_noseWidth, nil)
        case .lipsThickness:
            return (GLMPLanguage.faceAttributes_question_lipsThickness, nil)
        case .lipsShape:
            return (GLMPLanguage.faceAttributes_question_lipsShape, nil)
        case .skinType:
            return (GLMPLanguage.faceAttributes_question_skinType, GLMPLanguage.faceAttributes_question_skinType_subtitle)
        case .skinTone:
            return (GLMPLanguage.faceAttributes_question_skinTone, nil)
        case .skinBlemishes:
            return (GLMPLanguage.faceAttributes_question_skinBlemishes, GLMPLanguage.faceAttributes_question_skinBlemishes_subtitle)
        }
    }
    
    // MARK: - Option Titles
    
    static func getOptionTitle(for value: String) -> String {
        switch value {
        // Age Range
        case AgeRange.under18.rawValue: return GLMPLanguage.faceAttributes_age_under18
        case AgeRange.age19to25.rawValue: return GLMPLanguage.faceAttributes_age_19to25
        case AgeRange.age26to35.rawValue: return GLMPLanguage.faceAttributes_age_26to35
        case AgeRange.age36to45.rawValue: return GLMPLanguage.faceAttributes_age_36to45
        case AgeRange.over45.rawValue: return GLMPLanguage.faceAttributes_age_over45
        
        // Face Shape
        case FaceShape.round.rawValue: return GLMPLanguage.faceAttributes_faceShape_round
        case FaceShape.oval.rawValue: return GLMPLanguage.faceAttributes_faceShape_oval
        case FaceShape.square.rawValue: return GLMPLanguage.faceAttributes_faceShape_square
        case FaceShape.oblong.rawValue: return GLMPLanguage.faceAttributes_faceShape_oblong
        case FaceShape.heart.rawValue: return GLMPLanguage.faceAttributes_faceShape_heart
        case FaceShape.invertedTriangle.rawValue: return GLMPLanguage.faceAttributes_faceShape_invertedTriangle
        
        // Cheekbone
        case CheekboneProminence.high.rawValue: return GLMPLanguage.faceAttributes_cheekbone_high
        case CheekboneProminence.normal.rawValue: return GLMPLanguage.faceAttributes_cheekbone_normal
        case CheekboneProminence.low.rawValue: return GLMPLanguage.faceAttributes_cheekbone_low
        
        // Jawline
        case JawlineType.round.rawValue: return GLMPLanguage.faceAttributes_jawline_round
        case JawlineType.sharp.rawValue: return GLMPLanguage.faceAttributes_jawline_sharp
        case JawlineType.square.rawValue: return GLMPLanguage.faceAttributes_jawline_square
        case JawlineType.defined.rawValue: return GLMPLanguage.faceAttributes_jawline_defined
        
        // Chin
        case ChinShape.pointed.rawValue: return GLMPLanguage.faceAttributes_chin_pointed
        case ChinShape.round.rawValue: return GLMPLanguage.faceAttributes_chin_round
        case ChinShape.wide.rawValue: return GLMPLanguage.faceAttributes_chin_wide
        
        // Eye Size
        case EyeSize.small.rawValue: return GLMPLanguage.faceAttributes_eyeSize_small
        case EyeSize.normal.rawValue: return GLMPLanguage.faceAttributes_eyeSize_normal
        case EyeSize.large.rawValue: return GLMPLanguage.faceAttributes_eyeSize_large
        
        // Eye Shape
        case EyeShape.monolid.rawValue: return GLMPLanguage.faceAttributes_eyeShape_monolid
        case EyeShape.doubleLid.rawValue: return GLMPLanguage.faceAttributes_eyeShape_doubleLid
        case EyeShape.innerDouble.rawValue: return GLMPLanguage.faceAttributes_eyeShape_innerDouble
        case EyeShape.puffy.rawValue: return GLMPLanguage.faceAttributes_eyeShape_puffy
        
        // Eye Distance
        case EyeDistance.wide.rawValue: return GLMPLanguage.faceAttributes_eyeDistance_wide
        case EyeDistance.normal.rawValue: return GLMPLanguage.faceAttributes_eyeDistance_normal
        case EyeDistance.narrow.rawValue: return GLMPLanguage.faceAttributes_eyeDistance_narrow
        
        // Eyebrow Shape
        case EyebrowShape.straight.rawValue: return GLMPLanguage.faceAttributes_eyebrow_straight
        case EyebrowShape.curved.rawValue: return GLMPLanguage.faceAttributes_eyebrow_curved
        case EyebrowShape.arched.rawValue: return GLMPLanguage.faceAttributes_eyebrow_arched
        case EyebrowShape.angular.rawValue: return GLMPLanguage.faceAttributes_eyebrow_angular
        
        // Nose Length
        case NoseLength.short.rawValue: return GLMPLanguage.faceAttributes_noseLength_short
        case NoseLength.normal.rawValue: return GLMPLanguage.faceAttributes_noseLength_normal
        case NoseLength.long.rawValue: return GLMPLanguage.faceAttributes_noseLength_long
        
        // Nose Width
        case NoseWidth.narrow.rawValue: return GLMPLanguage.faceAttributes_noseWidth_narrow
        case NoseWidth.normal.rawValue: return GLMPLanguage.faceAttributes_noseWidth_normal
        case NoseWidth.wide.rawValue: return GLMPLanguage.faceAttributes_noseWidth_wide
        
        // Lips Thickness
        case LipsThickness.thin.rawValue: return GLMPLanguage.faceAttributes_lipsThickness_thin
        case LipsThickness.medium.rawValue: return GLMPLanguage.faceAttributes_lipsThickness_medium
        case LipsThickness.thick.rawValue: return GLMPLanguage.faceAttributes_lipsThickness_thick
        
        // Lips Shape
        case LipsShape.topHeavy.rawValue: return GLMPLanguage.faceAttributes_lipsShape_topHeavy
        case LipsShape.bottomHeavy.rawValue: return GLMPLanguage.faceAttributes_lipsShape_bottomHeavy
        case LipsShape.balanced.rawValue: return GLMPLanguage.faceAttributes_lipsShape_balanced
        
        // Skin Type
        case SkinType.dry.rawValue: return GLMPLanguage.faceAttributes_skinType_dry
        case SkinType.oily.rawValue: return GLMPLanguage.faceAttributes_skinType_oily
        case SkinType.normal.rawValue: return GLMPLanguage.faceAttributes_skinType_normal
        case SkinType.combination.rawValue: return GLMPLanguage.faceAttributes_skinType_combination
        case SkinType.sensitive.rawValue: return GLMPLanguage.faceAttributes_skinType_sensitive
        
        // Skin Tone
        case SkinTone.light.rawValue: return GLMPLanguage.faceAttributes_skinTone_light
        case SkinTone.medium.rawValue: return GLMPLanguage.faceAttributes_skinTone_medium
        case SkinTone.golden.rawValue: return GLMPLanguage.faceAttributes_skinTone_golden
        case SkinTone.dark.rawValue: return GLMPLanguage.faceAttributes_skinTone_dark
        
        // Skin Blemishes
        case SkinBlemishes.noneOrFew.rawValue: return GLMPLanguage.faceAttributes_skinBlemishes_noneOrFew
        case SkinBlemishes.moderate.rawValue: return GLMPLanguage.faceAttributes_skinBlemishes_moderate
        case SkinBlemishes.many.rawValue: return GLMPLanguage.faceAttributes_skinBlemishes_many
        
        default: return value
        }
    }
}

