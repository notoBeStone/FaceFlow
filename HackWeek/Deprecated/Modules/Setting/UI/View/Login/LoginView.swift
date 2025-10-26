//
//  LoginView.swift
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
struct Login_Preview: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(), actionModel: LoginActionModel())
    }
}
#endif

class LoginActionModel: ObservableObject {
    var backAction = PassthroughSubject<Void, Never>()
    var forgotPasswordAction = PassthroughSubject<Void, Never>()
    var loginAction = PassthroughSubject<Void, Never>()
    var signupAction = PassthroughSubject<Void, Never>()
    var appleAction = PassthroughSubject<Void, Never>()
}

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @ObservedObject var actionModel: LoginActionModel
    
    @State private var emailEditing: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    
                    Text(GLMPLanguage.text_forgot_password)
                        .textStyle(.footnoteMedium)
                        .foregroundColor(.p5)
                        .multilineTextAlignment(.center)
                        .controlSize(.large)
                        .onTapGesture {
                            actionModel.forgotPasswordAction.send()
                        }
                }
                .padding(.top, 40.rpx)
                
                // login
                VStack(spacing: 16.rpx) {
                    
                    GLButton(text: GLMPLanguage.text_login, layout: .fill, size: .medium, state: viewModel.btnState) {
                        gl_endEditing()
                        guard viewModel.btnState == .default else {
                            return
                        }
                        actionModel.loginAction.send()
                    }
                    .frame(maxWidth: .infinity)
                    
                    AttributedText(String(format: "%@ %@", GLMPLanguage.login_to_signup_desc, GLMPLanguage.text_sign_up))
                        .addTextAttribute(
                            font: .footnoteRegular,
                            foregroundColor: .g6,
                            kern: -0.31,
                            lineHeight: 22.rpx
                        )
                        .addTextAttribute(
                            subString: GLMPLanguage.text_sign_up,
                            font: .footnoteMedium,
                            foregroundColor: .p5
                        )
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            actionModel.signupAction.send()
                        }
                        
                    
                }
                .padding(.top, 30.rpx)
                
                LoginDivider()
                    .padding(.top, 24.rpx)
                
                HStack {
                    GLButton(text: GLMPLanguage.text_sign_in_apple, image: Image("icon_ios"), foregroundColor: .g9, backgroundColor: .clear, applyForegroundColorToImage: true, borderWidth: 1, borderColor: .g9, layout: .fill, style: .outlined, size: .medium) {
                        actionModel.appleAction.send()
                    }
                }
                .padding(.top, 24.rpx)
                
                
                Spacer()
                
                TermsPolicyView()
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


fileprivate struct LoginDivider: View {
    var body: some View {
        HStack(alignment: .center, spacing: 32.rpx) {
            Rectangle()
                .foregroundColor(Color.g3)
                .frame(height: 0.5)
            
            Text(GLMPLanguage.namecard_text_or)
                .textStyle(.caption1Regular)
                .foregroundColor(.g4)
                .lineLimit(1)
            
            Rectangle()
                .foregroundColor(Color.g3)
                .frame(height: 0.5)
        }
        .padding(.vertical, 16.rpx)
        .frame(maxWidth: .infinity)
    }
}
