//
//  TrialCancelSurveyView.swift
//  KnitAI
//
//  Created by stephenwzl on 2025/1/23.
//

import SwiftUI
import GLUtils
import GLMP
import GLTrackingExtension
import IQKeyboardManager
import GLCore
import GLAccountExtension

struct TrialCancelSurveyView: View, GLSwiftUIPageTrackable {
    var trackerPageName: String? = "trialcancelsurvey"
    
    var trackerPageParams: [String : Any]? {
        [
            .TRACK_KEY_TYPE: SurveyCancelType.currentType.rawValue
        ]
    }
    
    // 回调参数
    var onDismissAction: (() -> Void)?
    var onSubmitAction: (() -> Void)?
    
    let options = TrialCancelReason.allCases
    @State var currentSelections: [TrialCancelReason: Bool] = [:]
    @State var inputs: [TrialCancelReason : String] = [:]
    
    var isEnabled: Bool {
        return currentSelections.keys.isEmpty == false
    }
    
    var isTrialCancelledType = SurveyCancelType.isTrialVipCancelAutoReview() || SurveyCancelType.isSoonExpire()
    var isCancelledVipType = SurveyCancelType.isCancelledVip()
    var expireDays = SurveyCancelType.expireDays()
    
    func renderTrialCancelledText(days: Int) -> AnyView {
        if days == 0 {
            return Text("Your membership will expire today. What’s the main reason you would end your subscription?")
                .fontMedium(17.rpx)
                .foregroundColor(.g9L)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20.rpx)
                .padding(.bottom, 24.rpx)
                .padding(.top, 4.rpx)
                .anyView
        }
        return (
            Text("Your membership expires in")
                .fontMedium(17.rpx)
                .foregroundColor(.g9L)
            +
            Text(" \(days) ")
                .fontBold(20.rpx)
                .foregroundColor(Color.themeColor)
            +
            Text("days.\nWhat’s the main reason you would end your subscription?")
                .fontMedium(17.rpx)
                .foregroundColor(.g9L)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 20.rpx)
        .padding(.bottom, 24.rpx)
        .padding(.top, 4.rpx)
        .anyView
    }
    
    func renderCancelledText() -> AnyView {
        Text("Your premium membership has been expired. What’s the biggest reason for you cancelling?")
            .fontMedium(17.rpx)
            .foregroundColor(.g9L)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20.rpx)
            .padding(.bottom, 24.rpx)
            .padding(.top, 4.rpx)
            .anyView
    }
    
    var body: some View {
        VStack {
            (
                Text("💖")
                    .fontMedium(38.rpx)
                +
                Text(" We want to serve better!")
                    .fontBold(22.rpx)
            )
            .fontColor(.g9L)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20.rpx)
            .padding(.top, Consts.safeTop + 44.rpx)
            
            if isTrialCancelledType && expireDays >= 0 {
                renderTrialCancelledText(days: expireDays)
            } else {
                renderCancelledText()
            }
            
            ScrollView {
                VStack(spacing: 12.rpx) {
                    ForEach(options) { item in
                        TrialCancelOptionView(item: item,
                                              isEnabled: currentSelections[item] ?? false,
                                              input: Binding(get: {
                            inputs[item] ?? ""
                        }, set: { newValue in
                            inputs[item] = newValue
                        }),
                                              onTap: { select in
                            if select {
                                currentSelections[item] = true
                            } else {
                                currentSelections.removeValue(forKey: item)
                            }
                        })
                    }
                }
                .padding(.horizontal, 20.rpx)
                .padding(.bottom, 24.rpx)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .keyboardObserving()
            VStack {
                Button {
                    if !isEnabled {
                        return
                    }
                    var value = ""
                    currentSelections.forEach { (key, selected) in
                        if selected {
                            value += key.rawValue
                            value += ":"
                            value += inputs[key] ?? ""
                            value += ";"
                        }
                    }
                    GLMPTracking.tracking("trialcancelsurvey_submit_click", parameters: [GLT_PARAM_CONTENT: value])
                    
                    // 调用回调或默认关闭
                    if let onSubmitAction = onSubmitAction {
                        onSubmitAction()
                    } else {
                        Navigator.dismiss()
                    }
                } label: {
                    Text("Submit")
                        .fontBold(20.rpx)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24.rpx)
                        .height(48.rpx)
                        .background(
                            Capsule().fill(isEnabled ? Color.themeColor : Color.themeColor.opacity(0.3))
                        )
                    
                }
                .padding(.horizontal, 20.rpx)
                
                Button {
                    // 调用回调或默认关闭
                    if let onDismissAction = onDismissAction {
                        onDismissAction()
                    } else {
                        Navigator.dismiss()
                    }
                } label: {
                    Text("Not Now")
                        .fontBold(16.rpx)
                        .foregroundStyle(Color(hex: 0x7a8998))
                }
                .controlSize(.large)
                .padding(.vertical, 12.rpx)
            }
            .padding(.bottom, Consts.safeBottom)
            .padding(.top, 16.rpx)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
        .background(Color.backgroundWhiteColor)
        .onAppear {
            IQKeyboardManager.shared().isEnabled = false
        }
        .onDisappear {
            IQKeyboardManager.shared().isEnabled = true
        }
    }
}

struct TrialCancelOptionView: View {
    let item: TrialCancelReason
    var isEnabled: Bool
    @Binding var input: String
    let onTap: (Bool) -> Void
    @State var isFirstResponder: Bool = false
    var body: some View {
        VStack {
            HStack(spacing: 12.rpx) {
                Text(item.desc)
                    .fontMedium(16.rpx)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.g9L)
                    .multilineTextAlignment(.leading)
                Image(isEnabled ? .commonCheckboxSelected : .commonCheckboxUnselected)
                    .resizable()
                    .frame(width: 24.rpx, height: 24.rpx)
            }
            .padding(.horizontal, 16.rpx)
            .padding(.vertical, 24.rpx)
            .background(
                RoundedRectangle(cornerRadius: 20.rpx)
                    .fill(isEnabled ? Color.themeColor.opacity(0.1) : Color.white)
            )
            .overlay {
                if isEnabled {
                    RoundedRectangle(cornerRadius: 20.rpx)
                        .inset(by: 2)
                        .stroke(Color.themeColor, lineWidth: 2)
                }
            }
            .onTapGesture {
                onTap(!isEnabled)
            }
            .gl_shadow(style: .sD1)
            if isEnabled {
                ZStack {
                    DynamicTextView(color: .g9L, font: .monserrat(14.rpx), config: .init(minHeight: 84, maxHeight: 84, lineSpacing: nil, maxCount: nil, accentColor: nil), text: $input, isFirstResponse: $isFirstResponder) {
                        // TODO
                    }
                    .frame(maxWidth: .infinity)
                    .background(alignment: .topLeading) {
                        if input.isEmpty {
                            Text("Please tell us about your experience here")
                                .fontRegular(14.rpx)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(Color(hex: 0xb7c1cc))
                        }
                    }
                    .padding(.horizontal, 16.rpx)
                    .padding(.vertical, 12.rpx)
                    
                }
                .background(
                    RoundedRectangle(cornerRadius: 20.rpx)
                        .fill(Color(hex: 0xececf5))
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview {
    TrialCancelSurveyView()
}
#endif

enum SurveyCancelType: String {
    case trialCancelled
    case expireSoon
    case expired
    case unknown
    
    static var currentType: SurveyCancelType {
        if Self.isTrialVipCancelAutoReview() {
            return .trialCancelled
        } else if Self.isSoonExpire() {
            return .expireSoon
        } else if Self.isCancelledVip() {
            return .expired
        } else {
            return .unknown
        }
    }
    
    
    static func isSoonExpire() -> Bool {
        guard let vipInfo = GL().Account_GetVipInfo(), GL().Account_IsVip() else {
            return false
        }
        guard vipInfo.isTrial.boolValue == false else {
            return false
        }
        guard vipInfo.isAutoRenew.boolValue == false else {
            return false
        }
        guard let expiredAt = vipInfo.expiredAt else {
            return false
        }
        let date = Date(timeIntervalSince1970: expiredAt.doubleValue)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days <= 7 && days >= 0
    }
    
    ///试用期取订
    static func isTrialVipCancelAutoReview() -> Bool {
        guard let vipInfo = GL().Account_GetVipInfo(), GL().Account_IsVip() else {
            return false
        }
        guard vipInfo.isTrial.boolValue else {
            return false
        }
        guard vipInfo.isAutoRenew.boolValue == false else {
            return false
        }
        return true
    }
    
    static func isCancelledVip() -> Bool {
        guard let vipInfo = GL().Account_GetVipInfo(), !GL().Account_IsVip() else {
            return false
        }
        if vipInfo.isVipInHistory.boolValue || vipInfo.isTrialAndExpired.boolValue {
            return true
        }
        return false
    }
    
    static func expireDays() -> Int {
        guard let vipInfo = GL().Account_GetVipInfo(), GL().Account_IsVip() else {
            return -1
        }
        let date = Date(timeIntervalSince1970: vipInfo.expiredAt.doubleValue)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? -1
        return days
    }
}

enum TrialCancelReason: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    case tooExpensive
    case preferDifferentPlan
    case noFeatureLiked
    case noValueFound
    case noUseEnough
    case othersSpecify
    
    var desc: String {
        switch self {
        case .tooExpensive:
            return "I find the price too expensive"
        case .preferDifferentPlan:
            return "I prefer a monthly or yearly plan"
        case .noFeatureLiked:
            return "It didn’t have the feature I wanted"
        case .noValueFound:
            return "I didn’t find the membership valuable"
        case .noUseEnough:
            return "I don’t use the app enough"
        case .othersSpecify:
            return "Others (please specify)"
        }
    }
}
