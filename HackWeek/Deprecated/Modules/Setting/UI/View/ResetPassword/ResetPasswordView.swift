//
//  ResetPasswordView.swift
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
struct ResetPassword_Preview: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(viewModel: ResetPasswordViewModel(), actionModel: ResetPasswordActionModel())
    }
}
#endif

class ResetPasswordActionModel: ObservableObject {
    var backAction = PassthroughSubject<Void, Never>()
    var continueAction = PassthroughSubject<Void, Never>()
    var resendCodeAction = PassthroughSubject<Void, Never>()
    var verifyCodeAction = PassthroughSubject<Void, Never>()
    var changePasswordAction = PassthroughSubject<Void, Never>()
}

struct ResetPasswordView: View {
    @ObservedObject var viewModel: ResetPasswordViewModel
    @ObservedObject var actionModel: ResetPasswordActionModel
    
    var body: some View {
        
        GLNavigationBar {
            
            Group {
                switch viewModel.step {
                case .inputEmail:
                    VStack {
                        InputEmailView()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .checkCode:
                    VStack {
                        CheckEmailCodeView()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .resetPassword:
                    VStack {
                        NewPasswordView()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .environmentObject(viewModel)
            .environmentObject(actionModel)
        }
        .setBackLeadingItem {
            actionModel.backAction.send()
        }
        .setTitle(viewModel.step.title)
        .background(Color.g0)
        .contentShape(Rectangle())
        .onTapGesture {
            gl_endEditing()
        }
    }
}


fileprivate struct InputEmailView: View {
    
    @EnvironmentObject var viewModel: ResetPasswordViewModel
    @EnvironmentObject var actionModel: ResetPasswordActionModel
    
    @State var isEditing: Bool = false
    
    var body: some View {
        
        VStack(spacing: 30.rpx) {
            HStack(spacing: 0) {
                GLTextField(placeholder: GLMPLanguage.text_reset_password_hint, text: $viewModel.email, isFocused: $isEditing)
                    .frame(height: 22.rpx)
                
                if isEditing && viewModel.email.count > 0 {
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
            .frame(maxWidth: .infinity)
            .background(Color.g1N)
            .cornerRadius(8.rpx)
            
            GLButton(text: GLMPLanguage.text_continue, layout: .fill, size: .medium, state: viewModel.continueBtnState) {
                gl_endEditing()
                
                guard viewModel.continueBtnState == .default else {
                    return
                }
                
                actionModel.continueAction.send()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16.rpx)
        .padding(.vertical, 16.rpx)
    }
}



fileprivate struct CheckEmailCodeView: View {
    
    @EnvironmentObject var viewModel: ResetPasswordViewModel
    @EnvironmentObject var actionModel: ResetPasswordActionModel
    
    @State private  var isEditing: Bool = false
    
    var body: some View {
        
        VStack(spacing: 30.rpx) {
            
            VStack(spacing: 12.rpx) {
                
                AttributedText(GLMPLanguage.text_send_code_hint.gl_format(viewModel.formatedEmail))
                .addTextAttribute(
                    font: .caption1Regular,
                    foregroundColor: .g6,
                    kern: -0.15,
                    lineHeight: 18.rpx
                )
                .addTextAttribute(
                    subString: viewModel.formatedEmail,
                    foregroundColor: .p5
                )
                .multilineTextAlignment(.leading)
                
                
                HStack(spacing: 0) {
                    GLTextField(placeholder: GLMPLanguage.text_enter_code_hint, text: $viewModel.checkCode, isFocused: $isEditing)
                        .keyboardType(.asciiCapable)
                        .frame(height: 22.rpx)
                    
                    if isEditing && viewModel.checkCode.count > 0 {
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
                                viewModel.checkCode = ""
                            }
                    } else {
                        if viewModel.remainingCount > 0 {
                            Text("\(GLMPLanguage.text_resend) \(String(format: "%2d", viewModel.remainingCount))s")
                                .textStyle(.caption1Regular)
                                .foregroundColor(.g5)
                        } else {
                            Text(GLMPLanguage.text_resend)
                                .textStyle(.caption1Regular)
                                .foregroundColor(.p5)
                                .controlSize(.large)
                                .onTapGesture {
                                    actionModel.resendCodeAction.send()
                                }
                        }
                    }
                }
                .padding(.horizontal, 16.rpx)
                .padding(.vertical, 12.rpx)
                .frame(maxWidth: .infinity)
                .background(Color.g1N)
                .cornerRadius(8.rpx)
            }
            
            GLButton(text: GLMPLanguage.text_verify, layout: .fill, size: .medium, state: viewModel.verifyBtnState) {
                gl_endEditing()
                guard viewModel.verifyBtnState == .default else {
                    return
                }
                actionModel.verifyCodeAction.send()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16.rpx)
        .padding(.vertical, 16.rpx)
    }
}



fileprivate struct NewPasswordView: View {
    
    @EnvironmentObject var viewModel: ResetPasswordViewModel
    @EnvironmentObject var actionModel: ResetPasswordActionModel
    
    var body: some View {
        
        VStack(spacing: 30.rpx) {
            
            VStack(spacing: 12.rpx) {
                HStack {
                    GLTextField(placeholder: GLMPLanguage.text_password, text: $viewModel.password)
                        .setSecureText(viewModel.passwordSecure)
                        .frame(height: 22.rpx)
                        
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(
                            Image(viewModel.passwordSecure ? "icon_read_outlined" : "icon_readopen_outlined")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(.g5)
                        )
                        .frame(width: 20.rpx, height: 20.rpx)
                        .controlSize(.large)
                        .onTapGesture {
                            viewModel.passwordSecure.toggle()
                        }
                }
                .padding(.horizontal, 16.rpx)
                .padding(.vertical, 12.rpx)
                .background(Color.g1N)
                .cornerRadius(8.rpx)
                
                HStack {
                    GLTextField(placeholder: GLMPLanguage.text_confirm_password, text: $viewModel.confirmPassword)
                        .setSecureText(viewModel.confirmPasswordSecure)
                        .frame(height: 22.rpx)
                        
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(
                            Image(viewModel.confirmPasswordSecure ? "icon_read_outlined" : "icon_readopen_outlined")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(.g5)
                        )
                        .frame(width: 20.rpx, height: 20.rpx)
                        .controlSize(.large)
                        .onTapGesture {
                            viewModel.confirmPasswordSecure.toggle()
                        }
                }
                .padding(.horizontal, 16.rpx)
                .padding(.vertical, 12.rpx)
                .background(Color.g1N)
                .cornerRadius(8.rpx)
            }
            
            GLButton(text: GLMPLanguage.text_change_password, layout: .fill, size: .medium, state: viewModel.changeBtnState) {
                gl_endEditing()
                guard viewModel.changeBtnState == .default else {
                    return
                }
                actionModel.changePasswordAction.send()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16.rpx)
        .padding(.vertical, 16.rpx)
    }
}
