//
//  ResetPasswordViewModel.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import GLWidget
import Combine
import GLMP


class ResetPasswordViewModel: ObservableObject {
    
    enum Step {
        case inputEmail
        case checkCode
        case resetPassword
        
        var title: String {
            switch self {
            case .checkCode:
                return GLMPLanguage.text_check_your_email
            default:
                return GLMPLanguage.text_reset_your_password
            }
        }
    }
    
    @Published var step: Step = .inputEmail
    
    
    //input email page
    @Published var email: String = "" {
        didSet {
            formatedEmail = (email as NSString).gl_stringByTrim()
        }
    }
    @Published var formatedEmail: String = ""
    @Published var continueBtnState: GLButtonState = .disable
    
    //check code page
    @Published var checkCode: String = "" {
        didSet {
            formatedCheckCode = (checkCode as NSString).gl_stringByTrim()
        }
    }
    @Published var formatedCheckCode: String = ""
    
    @Published var verifyBtnState: GLButtonState = .disable
    @Published var remainingCount: Int = 60
    var timer: Timer?
    
    //reset password page
    @Published var password: String = ""
    @Published var passwordSecure: Bool = true
    @Published var confirmPassword: String = ""
    @Published var confirmPasswordSecure: Bool = true
    @Published var changeBtnState: GLButtonState = .disable
    
    init() {
        $formatedEmail.map { emailText in
            return emailText.isEmpty ? .disable : .default
        }.assign(to: &$continueBtnState)
        
        $formatedCheckCode.map { codeText in
            return codeText.isEmpty ? .disable : .default
        }.assign(to: &$verifyBtnState)
        
        Publishers.CombineLatest($password, $confirmPassword)
            .map { pwd, confirmPwd in
                return  pwd.count >= GLMPAccount.kPasswordMinLength && confirmPwd.count >= GLMPAccount.kPasswordMinLength ?  .default : .disable
            }
            .assign(to: &$changeBtnState)
    }

    //请求验证码
    func onRequestCheckCode(_ completion: @escaping (Bool, NSError?) -> Void) {
        GLToast.showLoading()
        let language = GLMPAppUtil.currentLanguage
        GLMPAccount.getVerifyCode(email: formatedEmail, languageCode: language.languageId) { [weak self] success, error in
            GLToast.dismiss()
            if success {
                self?.startTimer()
            }
            completion(success, error)
        }
    }
    
    //重发验证码
    func resendCode(_ completion: @escaping (Bool, NSError?) -> Void) {
        onRequestCheckCode(completion)
    }
    
    //校验验证码
    func onVerifyCode(_ completion: @escaping (Bool, NSError?) -> Void) {
        GLToast.showLoading()
        GLMPAccount.checkVerifyCode(email: formatedEmail, verifyCode: formatedCheckCode) { success, error in
            GLToast.dismiss()
            completion(success, error)
        }
    }
    
    
    //更新密码
    func onUpdatePassword(_ completion: @escaping (Bool, NSError?) -> Void) {
        GLToast.showLoading()
        GLMPAccount.resetPasswordAndLogin(email: formatedEmail, verifyCode: formatedCheckCode, password: password) { [weak self] success, error in
            if success {
                self?.login({ success, error in
                    GLToast.dismiss()
                    completion(success, error)
                })
            } else {
                GLToast.dismiss()
                completion(success, error)
            }
        }
    }
    
    //更新密码后重新登录
    private func login(_ completion: @escaping (Bool, NSError?) -> Void) {
        let language = GLMPAppUtil.currentLanguage
        GLMPAccount.loginWithEmail(email: formatedEmail, password: password, languageString: language.fullName, languageCode: language.languageId, completion: completion)
    }
    
    private func startTimer() {
        remainingCount = 60
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.remainingCount > 0 {
                self.remainingCount -= 1
            } else {
                timer.invalidate()
                self.timer = nil
            }
        }
        self.timer = timer
    }
    
}
