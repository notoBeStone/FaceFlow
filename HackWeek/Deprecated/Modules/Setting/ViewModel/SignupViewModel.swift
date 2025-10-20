//
//  SignupViewModel.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import GLWidget
import Combine
import GLMP

class SignupViewModel: ObservableObject {
    @Published var email: String = "" {
        didSet {
            formatedEmail = (email as NSString).gl_stringByTrim()
        }
    }
    
    @Published var formatedEmail: String = ""
    
    @Published var password: String = ""
    
    @Published var isSecure: Bool = true
    
    @Published var btnState: GLButtonState = .disable
    
    
    
    init() {
        Publishers.CombineLatest($formatedEmail, $password)
            .map { email, pw in
                return email.isEmpty || pw.isEmpty ? .disable : .default
            }
            .assign(to: &$btnState)
    }
    
    
    func onSignup(completion: @escaping (Bool, NSError?) -> Void) {
        guard LoginViewModel.checkEmail(formatedEmail) else { return }
        guard LoginViewModel.checkPassword(password) else { return }
        
        let language = GLMPAppUtil.currentLanguage
        GLToast.showLoading()
    
        GLMPAccount.signupWithEmail(email: formatedEmail, password: password, languageString: language.fullName, languageCode: language.languageId) { success, error in
            GLToast.dismiss()
            completion(success, error)
        }
    }

}
