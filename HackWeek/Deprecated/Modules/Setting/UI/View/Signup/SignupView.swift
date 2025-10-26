//
//  SignupView.swift
//  AINote
//
//  Created by user on 2024/8/14.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLWidget


#if DEBUG
struct Signup_Preview: PreviewProvider {
    static var previews: some View {
        SignupView(viewModel: SignupViewModel(), actionModel: SignupActionModel())
    }
}
#endif

class SignupActionModel: ObservableObject {
    var backAction = PassthroughSubject<Void, Never>()
    var signupAction = PassthroughSubject<Void, Never>()
    var gotoLoginAction = PassthroughSubject<Void, Never>()
}

struct SignupView: View {
    @ObservedObject var viewModel: SignupViewModel
    @ObservedObject var actionModel: SignupActionModel
    
    @State private var emailEditing: Bool = false
    
    var body: some View {
        GLNavigationBar {
            VStack(spacing: 0) {
                // header image
                HStack {
                    Image("logo_80")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.p5)
                        .frame(width: 137.rpx, height: 28.rpx)
                    
                }
                .padding(.horizontal, 16.rpx)
                .padding(.vertical, 8.rpx)
                .frame(maxWidth: .infinity)
                
                // input
                VStack(spacing: 12.rpx) {
                    
                    HStack {
                        GLTextField(placeholder: GLMPLanguage.text_email_address, text: $viewModel.email, isFocused: $emailEditing)
                            .textFont(.footnoteRegular)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .frame(height: 22.rpx)
                        
                        
                        if emailEditing && viewModel.email.count > 0 {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 20.rpx, height: 20.rpx)
                                .background(
                                    Image("icon_close_outlined_regular")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.g5)
                                        
                                )
                                .controlSize(.large)
                                .onTapGesture {
                                    viewModel.email = ""
                                }
                        }
                        
                    }
                    .padding(.horizontal, 16.rpx)
                    .padding(.vertical, 12.rpx)
                    .background(Color.g1N)
                    .cornerRadius(8.rpx)
                    
                    HStack {
                        GLTextField(placeholder: GLMPLanguage.text_password, text: $viewModel.password)
                            .setSecureText(viewModel.isSecure)
                            .frame(height: 22.rpx)
                            
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(
                                Image(viewModel.isSecure ? "icon_read_outlined" : "icon_readopen_outlined")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(.g5)
                            )
                            .frame(width: 20.rpx, height: 20.rpx)
                            .controlSize(.large)
                            .onTapGesture {
                                viewModel.isSecure.toggle()
                            }
                    }
                    .padding(.horizontal, 16.rpx)
                    .padding(.vertical, 12.rpx)
                    .background(Color.g1N)
                    .cornerRadius(8.rpx)
                }
                .padding(.top, 40.rpx)
                
                // login
                VStack(spacing: 16.rpx) {
                    
                    GLButton(text: GLMPLanguage.text_sign_up, layout: .fill, size: .medium, state: viewModel.btnState) {
                        gl_endEditing()
                        guard viewModel.btnState == .default else {
                            return
                        }
                        actionModel.signupAction.send()
                    }
                    .frame(maxWidth: .infinity)
                    
                    AttributedText(String(format: "%@ %@", GLMPLanguage.signup_to_login_desc, GLMPLanguage.text_login))
                        .addTextAttribute(
                            font: .footnoteRegular,
                            foregroundColor: .g6,
                            kern: -0.31,
                            lineHeight: 22.rpx
                        )
                        .addTextAttribute(
                            subString: GLMPLanguage.text_login,
                            font: .footnoteMedium,
                            foregroundColor: .p5
                        )
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            actionModel.gotoLoginAction.send()
                        }
                    
                }
                .padding(.top, 30.rpx)

                
                Spacer()
                
                VStack(alignment: .center, spacing: 12.rpx) {
                    
                    TermsPolicyView()
                    
                    Text(GLMPLanguage.signup_with_email_reason)
                    .font(.regular(12.rpx))
                    .foregroundColor(.g6)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    
                }
                .padding(.bottom, GLScreen.safeBottom + 16.rpx)
                
            }
            .padding(.horizontal, 16.rpx)
            .frame(maxWidth: .infinity)
        }
        .setBackLeadingItem {
            actionModel.backAction.send()
        }
        .background(Color.g0)
        .contentShape(Rectangle())
        .onTapGesture {
            gl_endEditing()
        }
    }
}
