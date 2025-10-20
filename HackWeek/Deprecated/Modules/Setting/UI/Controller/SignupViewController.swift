//
//  SignupViewController.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLWidget
import GLAnalyticsUI

#if DEBUG
struct SignupView_Preview: PreviewProvider {
    static var previews: some View {
        GLPreviewController {
            SignupViewController()
        }
    }
}
#endif

class SignupViewController: BaseViewController, GLAPageProtocol {
    var pageName: String? = "signup"
    var pageParams: [String : Any]?
    
    let viewModel = SignupViewModel()
    let actionModel = SignupActionModel()    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUI() {
        super.setUI()
        
    }
    
    override func setSwiftUIView() {
        super.setSwiftUIView()
        
        let swiftUIView = SignupView(viewModel: viewModel, actionModel: actionModel)
        view.addSwiftUI(viewController: GLHostingController(rootView: swiftUIView)) { make in
            if self.isHiddenNavigationBar {
                make.edges.equalToSuperview()
            } else {
                make.top.equalTo(self.navigationView.snp.bottom)
                make.bottom.leading.trailing.equalToSuperview()
            }
        }
    }
    
    override func setActions() {
        super.setActions()
        
        actionModel.backAction.sink { [weak self] in
            guard let self = self else { return }
            self.onBackAction()
        }.store(in: &cancellables)
        
        
        actionModel.signupAction.sink { [weak self] in
            guard let self = self else { return }
            self.onSignupAction()
        }.store(in: &cancellables)
        
        actionModel.gotoLoginAction.sink { [weak self] in
            guard let self = self else { return }
            self.onGotoLoginAction()
        }.store(in: &cancellables)
        
    }
    
    
    private func onBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func onSignupAction() {
        viewModel.onSignup { [weak self] success, error in
            if success {
                self?.navigationController?.popViewController(animated: true)
            } else if let error = error {
                if error.serverErrorCode() == 1027 {
                    UIAlertController.gl_alertController(withTitle: nil, message: GLMPLanguage.text_account_exist_title, buttonTitles: [GLMPLanguage.text_ok])
                }
            }
        }
    }
    
    private func onGotoLoginAction() {
        let loginVC = LoginViewController(from: self.pageName ?? "")
        self.navigationController?.gl_push(afterPopThenPush: loginVC, animated: true)
    }
}
