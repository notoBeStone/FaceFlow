//
//  File.swift
//  GLProgressiveProject
//
//  Created by stephenwzl on 2025/7/22.
//

import Foundation
import SwiftUI
import Combine
import GLCore
import GLPurchaseUIExtension
import GLAccountExtension
import GLResource
import AppConfig

public typealias ComposableTracking = (String, [String: Any]?) -> Void

public struct ComposableTrackingKey: EnvironmentKey {
    public static var defaultValue: ComposableTracking = {(_,_) in }
}

public extension EnvironmentValues {
    var tracking: ComposableTracking {
        get { self[ComposableTrackingKey.self] }
        set { self[ComposableTrackingKey.self] = newValue }
    }
}


open class ComposableViewModel: NSObject, ObservableObject {
    fileprivate struct TrackingEvent {
        let eventName: String
        let params: [String: Any]?
    }
    
    public struct UserInfo {
        let isVip: Bool
        let isVipInhistory: Bool
    }
    
    public enum VipAnimationType: Int {
        case present
        case aboveCurrent
        
        var rawType: GLPurchaseOpenType {
            switch self {
                case .present:
                    return .present
                case .aboveCurrent:
                    return .addChild
            }
        }
    }
    
    fileprivate let trackingEventPublisher = PassthroughSubject<TrackingEvent, Never>()
    
    public final func userInfo() -> UserInfo {
        let isVip = GL().Account_IsVip()
        let isVipInHistory = GL().Account_GetVipInfo()?.isVipInHistory.boolValue ?? false
        return .init(isVip: isVip, isVipInhistory: isVipInHistory)
    }
    
    public final func showVipPage(from: String, animationType: VipAnimationType = .present) {
        let conversion: String = GL().ABTesting_ValueForKey("conversion_page", activate: false) ?? ConversionConfig.defaultMemo
        _ = GL().PurchaseUI_Open(conversion, historyVipMemo: ConversionConfig.historyMemo, isVipInHistory: GL().Account_GetVipInfo()?.isVipInHistory.boolValue ?? false, vc: UIViewController.gl_top(), type: animationType.rawType,
                                 languageString: GLLanguage.currentLanguage.fullName,
                                 languageCode: GLLanguage.currentLanguage.languageId,
                                 from: from, identifyCount: 0, originGroup: nil, group: nil, abtestingID: nil, extra: [:]) { _, _ in
            return ""
        }
    }
    
    public final func tracking(_ eventName: String, _ params: [String: Any]? = nil) {
        trackingEventPublisher.send(.init(eventName: eventName, params: params))
    }
}

public extension View {
    func connect<VM: ComposableViewModel>(viewModel: VM) -> some View {
        return self.modifier(ViewModelConnectorModifier(viewModel: viewModel))
    }
}

private struct ViewModelConnectorModifier<VM: ComposableViewModel>: ViewModifier {
    @ObservedObject var viewModel: VM
    @Environment(\.tracking) var tracking
    
    func body(content: Content) -> some View {
        content
            .onReceive(viewModel.trackingEventPublisher) { event in
            tracking(event.eventName, event.params)
        }
    }
}
