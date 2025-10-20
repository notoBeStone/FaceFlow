//
//  AgreementItem.swift
//  AINote
//
//  Created by user on 2024/6/20.
//

import Foundation
import AppConfig
import GLMP

class AgreementItem: WorkflowItem {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        if let agreementMemo = AppLaunchConfig.agreementMemo {
            GLMPAgreement.initAgreement(with: agreementMemo)
        } else {
            GLMPAgreement.initAgreement()
        }
        
        GLMPAgreement.checkAgreement {
            completion(context)
        }
    }
    
}
