//
//  AppInfoView.swift
//  AINote
//
//  Created by user on 2024/8/12.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLWidget
import GLMP

#if DEBUG
struct AppInfo_Preview: PreviewProvider {
    static var previews: some View {
        AppInfoView(actionModel: AppInfoActionModel())
    }
}
#endif

class AppInfoActionModel: ObservableObject {
    var backAction = PassthroughSubject<Void, Never>()
    var thirdPartyAction = PassthroughSubject<String, Never>()
    var moreAboutUsAction = PassthroughSubject<Void, Never>()
}

struct AppInfoView: View {
    @ObservedObject var actionModel: AppInfoActionModel
    
    var body: some View {
        
        GLNavigationBar {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HeaderView()
                        
//                        ContentInfoView { urlString in
//                            actionModel.thirdPartyAction.send(urlString)
//                        }
                    }
                }
                
                BottomView {
                    actionModel.moreAboutUsAction.send()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .setBackLeadingItem({
            actionModel.backAction.send()
        })
        .background(alignment: .top) {
            Image("settings_about_bg")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .background(Color.g0)
    }
        
}

fileprivate struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16.rpx) {
            
            Image("settings_logo")
                .frame(width: 110.rpx, height: 110.rpx)
            
            
            VStack(alignment: .center, spacing: 4.rpx) {
                Text(GLMPAppUtil.appName)
                    .textStyle(.title4Bold)
                    .foregroundColor(.g9)
                    .multilineTextAlignment(.center)
                
                Text("Version \(GLMPAppUtil.appVersion)")
                    .textStyle(.footnoteRegular)
                    .foregroundColor(.g9)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        
    }
}


fileprivate struct ContentInfoView: View {
    
    let onThirdPartyNoticeAction: (String) -> Void
    
    private let thirdPartyNoticeUrl: String? = GLMPAccount.getClientConfig()?.legalConfig.thirdPartyNoticesUrl
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.rpx) {
            VStack(alignment: .leading, spacing: 16.rpx) {
                VStack(alignment: .leading, spacing: 6.rpx) {
                    Text(GLMPLanguage.text_about_us_list)
                    .textStyle(.footnoteRegular)
                    .foregroundColor(.g9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16.rpx)
            .padding(.vertical, 16.rpx)
            .frame(maxWidth: .infinity)
            .background(Color.gW)
            .cornerRadius(8.rpx)
            
            
            if let thirdPartyNoticeUrl = self.thirdPartyNoticeUrl, !thirdPartyNoticeUrl.isEmpty {
                HStack(spacing: 6.rpx) {
                    Image("icon_info_outlined_regular")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.g6)
                        .frame(width: 20.rpx, height: 20.rpx)
                    
                    
                    Text(GLMPLanguage.settings_aboutus_thirdpartynotices_title)
                        .textStyle(.footnoteMedium)
                        .foregroundColor(.g9)
                    
                    Spacer()
                    
                    Image("icon_goto_outlined_heavy")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.g5)
                        .frame(width: 16.rpx, height: 16.rpx)
                }
                .padding(.horizontal, 16.rpx)
                .padding(.vertical, 16.rpx)
                .frame(maxWidth: .infinity)
                .background(Color.gW)
                .cornerRadius(8.rpx)
                .gl_shadow(style: .sD3)
                .onTapGesture {
                    onThirdPartyNoticeAction(thirdPartyNoticeUrl)
                }
            }
        }
        .padding(.horizontal, 16.rpx)
        .padding(.vertical, 24.rpx)
        .frame(maxWidth: .infinity)
    }
}


fileprivate struct BottomView: View {
    
    let onMoreAboutUsAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
//            Text(GLMPLanguage.newuserlanding_agreementpage_botanistinyourpocket_title)
//                .font(.regular(22.rpx))
//                .foregroundColor(.g6)
            

            Text(GLMPLanguage.homepage_learnmoreaboutus_title)
                .underline()
                .font(.medium(14.rpx))
                .foregroundColor(.themeColor)
                .multilineTextAlignment(.center)
                .controlSize(.large)
                .onTapGesture {
                    onMoreAboutUsAction()
                }
        }
        .padding(.vertical, 16.rpx)
        .frame(maxWidth: .infinity)
        .background(Color.g0)
        .padding(.horizontal, 0)
        .padding(.bottom, GLScreen.safeBottom)
    }
}
