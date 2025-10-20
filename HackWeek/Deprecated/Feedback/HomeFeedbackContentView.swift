//
//  FinishTroubleView.swift
//  IOSProject
//
//  Created by Martin on 2024/9/3.
//

import SwiftUI
import GLUtils
import Combine
import SwiftUIIntrospect

struct HomeFeedbackContentView: View {
    @ObservedObject var viewModel: HomeFeedbackViewModel
    @State var email: String = ""
    @State var feedback: String = ""
    @State var isFirstResponse: Bool = false
    
    init(viewModel: HomeFeedbackViewModel) {
        self.viewModel = viewModel
        self._email = .init(initialValue: viewModel.result.email ?? "")
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                Spacer()
                Image("common_navclose_btn_32")
                    .size(width: 32.0)
                    .controlSize(.large)
                    .onTapGesture {
                        viewModel.actions.closeAction.send()
                    }
            }.padding(.horizontal, Consts.contentLeading)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0.0) {
                    VStack(spacing: 8.rpx) {
                        Text(GLMPLanguage.feedback_header_text)
                            .textStyle(font: .semibold(20.rpx), lineHeight: 30.rpx)
                            .foregroundColor(Color(hex: 0x000000))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30.rpx)
                        
                        Text(GLMPLanguage.feedback_instruction_text)
                            .textStyle(font: .regular(14.rpx), lineHeight: 24.rpx)
                            .foregroundColor(Color(hex: 0x7A8998))
                            .multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity)
                    
                    Text(GLMPLanguage.feedback_email_label)
                        .font(.semibold(16.rpx))
                        .foregroundColor(Color(hex: 0x000000))
                        .padding(.top, 24.rpx)
                    
                    ZStack(alignment: .leading) {
                        Text(GLMPLanguage.feedback_email_placeholder)
                            .font(textFont)
                            .foregroundColor(.g5)
                            .opacity(email.isEmpty ? 1.0 : 0.0)
                        
                        TextField("", text: $email)
                            .submitLabel(.done)
                            .accentColor(.themeColor)
                            .keyboardType(.emailAddress)
                            .font(textFont)
                            .foregroundColor(.gl_color(0x000000))
                    }
                    .padding(.vertical, 12.rpx)
                    .padding(.horizontal, 16.rpx)
                    .background(Color.systemC1)
                    .cornerRadius(16.rpx, corners: .allCorners)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8.rpx)
                    .introspectTextField { textField in
                        self.viewModel.actions.introspectTextEditorAction.send(.init(view: textField))
                    }
                    
                    Text(GLMPLanguage.feedback_opinion_label)
                        .font(.semibold(16.rpx))
                        .foregroundColor(Color(hex: 0x000000))
                        .padding(.top, 24.rpx)
                    
                    ZStack(alignment: .topLeading) {
                        if self.feedback.isEmpty {
                            Text(GLMPLanguage.feedback_opinion_placeholder)
                                .font(textFont)
                                .foregroundColor(.g5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        DynamicTextView(color: .gl_color(0x000000),
                                        font: textFont,
                                        config: .init(minHeight: 100.rpx, maxHeight: 100.rpx, lineSpacing: nil, maxCount: 512, accentColor: .themeColor),
                                        submitLabel: .done,
                                        fixedHeight: true,
                                        text: $feedback,
                                        isFirstResponse: $isFirstResponse) {}
                            .introspectTextView{
                                self.viewModel.actions.introspectTextEditorAction.send(.init(view: $0))
                            }
                    }
                    .padding(.vertical, 12.rpx)
                    .padding(.horizontal, 16.rpx)
                    .frame(maxWidth: .infinity)
                    .background(Color.systemC1)
                    .cornerRadius(16.rpx, corners: .allCorners)
                    .padding(.top, 8.rpx)
                }
                .padding(.bottom, 100.0.rpx)
                .padding(.horizontal, Consts.contentLeading)
            }.padding(.top, -6.rpx)
            
            HStack(alignment: .center, spacing: 0) {
                Text(GLMPLanguage.feedback_submit_button_label)
                    .font(.semibold(16.rpx))
                    .foregroundColor(Color(hex: 0xFFFFFF))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16.rpx)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 48.rpx)
            .background(Color.themeColor)
            .clipShape(Capsule())
            .padding(.horizontal, Consts.contentLeading)
            .onTapGesture {
                self.submit()
            }
        }
//        .ignoresSafeArea()
        .padding(.top, 16.rpx)
        .padding(.bottom, Consts.safeBottom + 12.rpx)
        .onChange(of: self.email) { newValue in
            self.viewModel.result.email = newValue.trimmingWhitespacesAndNewlines
        }
        .onChange(of: self.feedback) { newValue in
            self.viewModel.result.description = newValue.trimmingWhitespacesAndNewlines
        }
    }
    
    var textFont: Font {
        .regular(14.rpx)
    }
    
    private func limitText(_ upper: Int = 512) {
        if self.feedback.count > upper {
            self.feedback = String(self.feedback.prefix(upper))
        }
    }
    
    var mailValid: Bool {
        (self.email.trimmingWhitespacesAndNewlines as NSString).gl_validEmail()
    }
    
    private func submit() {
        self.viewModel.actions.submitAction.send()
    }
}
