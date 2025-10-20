//
//  ResetPasswordViewController.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLAnalyticsUI

#if DEBUG
struct ResetPasswordView_Preview: PreviewProvider {
    static var previews: some View {
        GLPreviewController {
            ResetPasswordViewController()
        }
    }
}
#endif

class ResetPasswordViewController: BaseViewController, GLAPageProtocol {
    var pageName: String? = "resetpassword"
    var pageParams: [String : Any]?
    let viewModel = ResetPasswordViewModel()
    let actionModel = ResetPasswordActionModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUI() {
        super.setUI()
        
    }
    
    override func setSwiftUIView() {
        super.setSwiftUIView()
        
        let swiftUIView = ResetPasswordView(viewModel: viewModel, actionModel: actionModel)
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
        
        actionModel.continueAction.sink { [weak self] in
            guard let self = self else { return }
            self.onContinueAction()
        }.store(in: &cancellables)
        
        actionModel.resendCodeAction.sink { [weak self] in
            guard let self = self else { return }
            self.onResendCodeAction()
        }.store(in: &cancellables)
        
        actionModel.verifyCodeAction.sink { [weak self] in
            guard let self = self else { return }
            self.onVerifyCodeAction()
        }.store(in: &cancellables)
        
        actionModel.changePasswordAction.sink { [weak self] in
            guard let self = self else { return }
            self.onChangePasswordAction()
        }.store(in: &cancellables)
    }
    
    
    private func onBackAction() {
        switch viewModel.step {
        case .inputEmail:
            self.navigationController?.popViewController(animated: true)
        case .checkCode:
            viewModel.step = .inputEmail
        case .resetPassword:
            viewModel.step = .checkCode
        }
    }
    
    
    private func onContinueAction() {
        guard LoginViewModel.checkEmail(viewModel.formatedEmail) else {
            return
        }
        
        viewModel.onRequestCheckCode { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.viewModel.step = .checkCode
            } else {
                if let error = error, error.serverErrorCode() == 1034 {
                    UIAlertController.gl_alertController(withTitle: nil, message: GLMPLanguage.text_no_account_found, buttonTitles: [GLMPLanguage.text_ok])
                    return
                }
                UIAlertController.gl_alertController(withTitle: nil, message: GLMPLanguage.text_failed, buttonTitles: [GLMPLanguage.text_ok])
            }
        }
    }
    
    private func onResendCodeAction() {
        viewModel.resendCode { success, error in
            if !success {
                UIAlertController.gl_alertController(withTitle: nil, message: GLMPLanguage.text_failed, buttonTitles: [GLMPLanguage.text_ok])
            }
        }
    }
    
    private func onVerifyCodeAction() {
        viewModel.onVerifyCode { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.viewModel.step = .resetPassword
            } else {
                UIAlertController.gl_alertController(withTitle: nil, message: GLMPLanguage.text_invalid_verify_code, buttonTitles: [GLMPLanguage.text_ok])
            }
        }
    }
    
    private func onChangePasswordAction() {
        
        guard viewModel.password == viewModel.confirmPassword else {
            UIAlertController.gl_alertController(withTitle: GLMPLanguage.text_different_password_title, message: GLMPLanguage.text_different_password_content, buttonTitles: [GLMPLanguage.text_ok])
            return
        }
        
        viewModel.onUpdatePassword { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.onSuccessAction()
            } else {
                UIAlertController.gl_alertController(withTitle: nil, message: GLMPLanguage.text_failed, buttonTitles: [GLMPLanguage.text_ok])
            }
        }
    }
    
    private func onSuccessAction() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
