//
//  LoginViewModel.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import GLWidget
import GLUtils
import GLMP
import GLModules
import Combine
import AuthenticationServices

class LoginViewModel: ObservableObject {
    
    @Published var email: String = "" {
        didSet {
            formatedEmail = (email as NSString).gl_stringByTrim()
        }
    }
    
    @Published var formatedEmail: String = ""
    
    @Published var password: String = ""
    
    @Published var isSecure: Bool = true
    
    @Published var btnState: GLButtonState = .disable
    
    
    private var appleLoginBlock: ((AppleLoginStatus, AppleUserAppModel?) -> Void)?
    
    init() {
        Publishers.CombineLatest($formatedEmail, $password)
            .map { email, pw in
                return email.isEmpty || pw.isEmpty ? .disable : .default
            }
            .assign(to: &$btnState)
    }
    
    
    static func checkEmail(_ email: String) -> Bool {
        var errorMsg: String? = nil
        if (email as NSString).gl_validEmail() == false {
            errorMsg = GLMPLanguage.text_invalid_email_address_content
        }
        if email.hasSuffix(".con") {
            errorMsg = GLMPLanguage.email_wrong_format_con
        }
        
        if let errorMsg = errorMsg {
            UIAlertController.gl_alertController(withTitle: errorMsg, buttonTitles: [GLMPLanguage.text_ok])
            return false
        }
        return true
    }
    
    static func checkPassword(_ password: String) -> Bool {
        guard !password.isEmpty else {
            return false
        }

        if password.count < GLMPAccount.kPasswordMinLength {
            UIAlertController.gl_alertController(withTitle: GLMPLanguage.text_empty_password_content, buttonTitles: [GLMPLanguage.text_ok])
            return false
        }
        return true
    }
    
    
    func onEmailLogin(_ completion: @escaping (Bool, NSError?) -> Void) {
        guard LoginViewModel.checkEmail(formatedEmail) else { return }
        guard LoginViewModel.checkPassword(password) else { return }
        
        let language = GLMPAppUtil.currentLanguage
        GLToast.showLoading()
        GLMPAccount.loginWithEmail(email: formatedEmail, password: password, languageString: language.fullName, languageCode: language.languageId) { success, error in
            GLToast.dismiss()
            completion(success, error)
        }
    }
    
    
    func onAppleLogin(completion: @escaping (Bool) -> Void) {
        guard let window = KeyWindow() else { return }
        GLToast.showLoading()
        AppleLoginManager.shared.onAppleLogin(with: window) { status, info in
            switch status {
            case .success:
                guard let info = info else {
                    completion(false)
                    return
                }
                let language = GLMPAppUtil.currentLanguage
                GLMPAccount.loginWithApple(user: info.user, mail: info.mail, name: info.name, token: info.token, languageString: language.fullName, languageCode: language.languageId) { success, error in
                    GLToast.dismiss()
                    completion(success)
                }
            default:
                GLToast.dismiss()
                completion(false)
            }
        }
    }
}




