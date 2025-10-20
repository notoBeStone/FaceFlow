//
//  LoginViewController.swift
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
import GLMP

#if DEBUG
struct LoginView_Preview: PreviewProvider {
    static var previews: some View {
        GLPreviewController {
            LoginViewController(from: "preview")
        }
    }
}
#endif

class LoginViewController: BaseViewController, GLAPageProtocol, GLMPRouterDeepLinkDelegate {
    var deeplink: DeepLink?
    
    required convenience init?(deeplink: DeepLink) {
        self.init(from: deeplink.from)
        self.deeplink = deeplink
    }
    
    var pageName: String? = "login"
    var pageParams: [String : Any]?
    
    let viewModel = LoginViewModel()
    let actionModel = LoginActionModel()    
    
    
    init(from: String) {
        super.init(from: from)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUI() {
        super.setUI()
    }
    
    override func setSwiftUIView() {
        super.setSwiftUIView()
        
        let swiftUIView = LoginView(viewModel: viewModel, actionModel: actionModel)
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
        
        actionModel.forgotPasswordAction.sink { [weak self] in
            guard let self = self else { return }
            self.onForgotPasswordAction()
        }.store(in: &cancellables)
        
        actionModel.loginAction.sink { [weak self] in
            guard let self = self else { return }
            self.onLoginAction()
        }.store(in: &cancellables)
        
        actionModel.signupAction.sink { [weak self] in
            guard let self = self else { return }
            self.onSignupAction()
        }.store(in: &cancellables)
        
        actionModel.appleAction.sink { [weak self] in
            guard let self = self else { return }
            self.onAppleLoginAction()
        }.store(in: &cancellables)
        
    }
    
    
    private func onBackAction() {
        self.popOrDismissController(defaultType: .pop, animated: true)
    }
    
    private func onForgotPasswordAction() {
        let vc = ResetPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func onLoginAction() {
        viewModel.onEmailLogin { [weak self] success, error in
            if success {
                self?.popOrDismissController(defaultType: .pop, animated: true)
            } else {
                GLToast.showError(GLMPLanguage.text_incorrect_email_password)
            }
        }
    }
    
    private func onSignupAction() {
        let vc = SignupViewController()
        self.navigationController?.gl_push(afterPopThenPush: vc, animated: true)
    }
    
    private func onAppleLoginAction() {
        viewModel.onAppleLogin { [weak self] success in
            if success {
                self?.popOrDismissController(defaultType: .pop, animated: true)
            } else {
                GLToast.showError(GLMPLanguage.text_login_fail)
            }
        }
    }
}
