//
//  ContactUsView.swift
//  AINote
//
//  Created by user on 2024/8/13.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLWidget

#if DEBUG
struct ContactUs_Preview: PreviewProvider {
    static var previews: some View {
        ContactUsView(viewModel: ContactUsViewModel(), actionModel: ContactUsActionModel())
    }
}
#endif

class ContactUsActionModel: ObservableObject {
    var backAction = PassthroughSubject<Void, Never>()
    var sendAction = PassthroughSubject<Void, Never>()
}

struct ContactUsView: View {
    @ObservedObject var viewModel: ContactUsViewModel
    @ObservedObject var actionModel: ContactUsActionModel
    
    var body: some View {
        GLNavigationBar {
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        //Text
                        HStack {
                            Text(GLMPLanguage.contactus_askfortechnicalsupport_guide)
                                .textStyle(.title5Regular)
                                .foregroundColor(.g9)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16.rpx)
                        .frame(maxWidth: .infinity)
                        
                        //Email
                        VStack(spacing: 16.rpx) {
                            AttributedText(GLMPLanguage.asktheexperts_basicinfo_title_youremailaddress + "*")
                                .addTextAttribute(
                                    font: .headlineBold,
                                    foregroundColor: .g9,
                                    kern: -0.45,
                                    lineHeight: 26.rpx
                                )
                                .addTextAttribute(
                                    subString: "*",
                                    foregroundColor: .f4
                                )
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            HStack(alignment: .top, spacing: 12.rpx) {
                                
                                GLTextField(placeholder: GLMPLanguage.asktheexperts_basicinfo_text_enteremailaddress, text: $viewModel.emailText)
                                    .textFont(.footnoteRegular)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                            }
                            .padding(.horizontal, 16.rpx)
                            .padding(.vertical, 12.rpx)
                            .frame(maxWidth: .infinity)
                            .background(Color.g1N)
                            .cornerRadius(8.rpx)
                            
                        }
                        .padding(16.rpx)
                        .frame(maxWidth: .infinity)
                        
                        
                        //Description
                        VStack(spacing: 16.rpx) {
                            AttributedText(GLMPLanguage.text_description + "*")
                                .addTextAttribute(
                                    font: .headlineBold,
                                    foregroundColor: .g9,
                                    kern: -0.45,
                                    lineHeight: 26.rpx
                                )
                                .addTextAttribute(
                                    subString: "*",
                                    foregroundColor: .f4
                                )
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            
                            
                            GLTextViewWrapper(text: $viewModel.descText, placeholder: GLMPLanguage.text_feedback_description_placeholder)
                                .frame(maxWidth: .infinity)
                                .frame(height: 80.rpx)
                                .cornerRadius(8.rpx)
                            
                            
                        }
                        .padding(16.rpx)
                        .frame(maxWidth: .infinity)
                        
                        
                        AddImagesView(images: $viewModel.images, maxImageCount: 3)
                        
                        Spacer()
                    }
                }
                
                HStack(spacing: 0) {
                    GLButton(text: GLMPLanguage.text_send, layout: .fill, size: .medium, state: viewModel.sendButtonState) {
                        actionModel.sendAction.send()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16.rpx)
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, GLScreen.safeBottom)
            .background(Color.g0)
            .onTapGesture {
                gl_endEditing()
            }
        }
        .setBackLeadingItem {
            actionModel.backAction.send()
        }
        .setTitle(GLMPLanguage.text_contact_us)
        .navigationBarBackground {
            Color.g0
        }
    }
}
