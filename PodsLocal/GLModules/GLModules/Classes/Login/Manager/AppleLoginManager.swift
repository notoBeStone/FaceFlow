//
//  AppleLoginManager.swift
//  Adjust
//
//  Created by user on 2024/8/15.
//

import Foundation
import AuthenticationServices

public class AppleLoginManager: NSObject {
    
    public static let shared = AppleLoginManager()
    
    private override init() { }
    
    private weak var window: UIWindow?
    private var appleLoginBlock: ((AppleLoginStatus, AppleUserAppModel?) -> Void)?
    
    
    // Apple login
    public func onAppleLogin(with window: UIWindow, completion: @escaping (AppleLoginStatus, AppleUserAppModel?) -> Void) {
        self.window = window
        self.appleLoginBlock = completion
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}


extension AppleLoginManager: ASAuthorizationControllerDelegate {

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var name: String = ""
            var token: String = ""
            if let fullName = credential.fullName {
                name = PersonNameComponentsFormatter.localizedString(from: fullName, style: .default)
            }
            if let identityToken = credential.identityToken, let str = String(data: identityToken, encoding: .utf8)  {
                token = str
            }
            
            let appleUser = AppleUserAppModel(user: credential.user, name: name, mail: credential.email ?? "", token: token)
            
            appleLoginBlock?(.success, appleUser)
            
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        var status: AppleLoginStatus = .failed
        if let authorizationError = error as? ASAuthorizationError, authorizationError.code == .canceled {
            status = .canceled
        }
        appleLoginBlock?(status, nil)
    }
}


extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.window ?? UIWindow()
    }
}
