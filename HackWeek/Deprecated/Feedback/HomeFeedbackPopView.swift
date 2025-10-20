//
//  FinishTroublePopView.swift
//  IOSProject
//
//  Created by Martin on 2024/9/3.
//

import UIKit
import GLTrackingExtension
import GLAnalyticsUI
import GLUtils
import Combine
import GLWidget

struct FinishTroubleResult {
    var email: String?
    var description: String?
    
    var parameters: [String: Any]? {
        var parameters = [String: Any]()
        if let email = self.email {
            parameters[GLT_PARAM_VALUE] = email
        }
        
        if let content = self.description {
            parameters[GLT_PARAM_CONTENT] = content
        }
        return parameters
    }
    
    var isEmpty: Bool {
        if let email, !email.isEmpty {
            return false
        }
        
        if let description, !description.isEmpty {
            return false
        }
        return true
    }
}

class HomeFeedbackPopView: BasePopUpView {
    let viewModel: HomeFeedbackViewModel
    var handler: ((_ result: FinishTroubleResult)->())?
    
    override init() {
        self.viewModel = .init()
        super.init(frame: ScreenBounds)
        configUI()
        addObserver()
        
        self.blankClickHandler = { [weak self] _ in
            self?.gl_track(type: .click, name: "blank")
            self?.close()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        let contentView = HomeFeedbackContentView(viewModel: viewModel)
        let hostViewController = GLHostingController(rootView: contentView)
        self.contentView.addSwiftUI(viewController: hostViewController) { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(ScreenHeight * 0.8)
            make.height.lessThanOrEqualTo(ScreenHeight * 0.9)
        }
    }
    
    private func addObserver() {
        let actions = viewModel.actions
        actions.closeAction.receive(on: RunLoop.main).sink {[weak self] _ in
            self?.closeAction()
        }.store(in: &cancellables)
        
        actions.submitAction.receive(on: RunLoop.main).sink {[weak self] _ in
            self?.submitAction()
        }.store(in: &cancellables)
    }
    
    // MARK: - Keyboard
    override var shouldResponseToKeyboard: Bool {
        return true
    }
    
    override var introspectTextEditorAction: PassthroughSubject<KeybaordAvoidCoveredTextEditor, Never>? {
        self.viewModel.actions.introspectTextEditorAction
    }
    
    // MARK: - Actions
    private func closeAction() {
        self.tracking("homefeedback_close_click")
        self.close()
    }
    
    private func submitAction() {
        self.tracking("homefeedback_submit_click")
        self.close()
    }
    
    private func close() {
        let result = self.viewModel.result
        self.dismiss(animated: true) {[weak self] in
            self?.handler?(result)
        }
    }
}

extension HomeFeedbackPopView: GLAPageProtocol {
    var pageName: String? {
        "homefeedback"
    }
    
    var pageParams: [String : Any]? {
        var parameters = [String: Any]()
        if let result = self.viewModel.result.parameters {
            parameters.append(result)
        }
        return parameters
    }
}
