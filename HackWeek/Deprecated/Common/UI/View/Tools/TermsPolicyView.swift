//
//  TermsPolicyView.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import GLWidget
import GLUtils
import GLConfig
import GLMP

#if DEBUG
struct TermsPolicyView_Preview: PreviewProvider {
    static var previews: some View {
        TermsPolicyView()
    }
    
}
#endif


struct TermsPolicyView: View {
    
    private static let termsOfUseUrl: String = "\(GLConfig.appScheme)://termsofuse"
    private static let privacyPolicyUrl: String = "\(GLConfig.appScheme)://privacypolicy"
    
    var body: some View {
        AttributedText(GLMPLanguage.login_private_policy_desc.gl_format(GLMPLanguage.protocol_termsofuse, GLMPLanguage.protocol_privacypolicy), onOpenLink: { url in
            let topVC = UIViewController.gl_top()
            if url.absoluteString == TermsPolicyView.termsOfUseUrl {
                GLMPAgreement.openTermsOfUse(with: topVC)
            } else if url.absoluteString == TermsPolicyView.privacyPolicyUrl {
                GLMPAgreement.openPrivacyPolicy(with: topVC)
            }
        })
            .addTextAttribute(
                font: .regular(12.rpx),
                foregroundColor: .g6,
                lineHeight: 16.rpx
            )
            .addTextAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .link: TermsPolicyView.termsOfUseUrl], subString: GLMPLanguage.protocol_termsofuse)
            .addTextAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .link: TermsPolicyView.privacyPolicyUrl], subString: GLMPLanguage.protocol_privacypolicy)
            .multilineTextAlignment(.center)
    }
}


