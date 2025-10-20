//
//  FinishTroubleViewModel.swift
//  IOSProject
//
//  Created by Martin on 2024/9/3.
//

import Foundation
import Combine
import UIKit

class HomeFeedbackViewModel: ObservableObject {
    var result: FinishTroubleResult = .init(email: "")
    let actions = FinishTroubleActions()
}

struct FinishTroubleActions {
    let closeAction = ObservableObjectPublisher()
    let submitAction = ObservableObjectPublisher()
    let introspectTextEditorAction = PassthroughSubject<KeybaordAvoidCoveredTextEditor, Never>()
}
