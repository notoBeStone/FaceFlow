//
//  GLOCVipBaseViewController+Learn.swift
//  Vip27547
//
//  Created by Martin on 2024/10/8.
//

import Foundation
import GLResource
import GLTrackingExtension

extension [AnyHashable: Any] {
    var learnLanguageType: GLLanguageEnum {
        guard let value = self[GLT_PARAM_INT5] as? Int, let type = GLLanguageEnum(rawValue: value) else {
            return .English
        }
        
        return type
    }
}
