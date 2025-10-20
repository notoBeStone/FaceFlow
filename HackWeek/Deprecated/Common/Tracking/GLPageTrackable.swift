//
//  GLPageTrackable.swift
//  KnitAI
//
//  Created by AI on 2024/03/21.
//

import SwiftUI
import GLAnalyticsUI
import GLCore
import GLTrackingExtension

/// 页面埋点协议
@available(iOS 13.0, *)
public protocol GLPageTrackable {
    /// 页面名称
    var pageName: String? { get }
    /// 页面公参
    var pageParams: [String: Any]? { get }
    /// 是否禁用当前页面的自动埋点
    var disableAutoTrack: Bool { get }
}

// MARK: - Default Implementation
@available(iOS 13.0, *)
public extension GLPageTrackable {
    var pageParams: [String: Any]? { nil }
    var disableAutoTrack: Bool { false }
    
    /// 发送自定义埋点事件
    /// - Parameters:
    ///   - type: 埋点类型
    ///   - name: 事件名称
    ///   - parameters: 额外参数
    func track(type: GLAPageTrackType, name: String, parameters: [String: Any]? = nil) {
        guard let pageName = pageName,
              let suffix = type.suffix else { return }
        
        // 事件名称
        let eventName = "\(pageName)_\(name)_\(suffix)".lowercased()
        
        // 合并参数
        var finalParams = parameters ?? [:]
        if let pageParams = pageParams {
            finalParams.merge(pageParams) { $1 }
        }
        
        GL().Tracking_Event(eventName, parameters: finalParams)
    }
}

// MARK: - ViewModifier
@available(iOS 13.0, *)
private struct PageTrackingModifier: ViewModifier {
    let trackable: GLPageTrackable
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                trackingShow()
            }
            .onDisappear {
                trackingHide()
            }
    }
    
    private func trackingShow() {
        guard let pageName = trackable.pageName,
              !pageName.isEmpty else { return }
        
        let responder = SwiftUITrackingHolding.shared.getBridgeResponder(pageName)
        responder._pageParams = trackable.pageParams
        responder._disableAutoTrack = trackable.disableAutoTrack
        GLAAutoTracking.show(responder)
    }
    
    private func trackingHide() {
        guard let pageName = trackable.pageName,
              !pageName.isEmpty else { return }
        
        let responder = SwiftUITrackingHolding.shared.getBridgeResponder(pageName)
        responder._pageParams = trackable.pageParams
        responder._disableAutoTrack = trackable.disableAutoTrack
        GLAAutoTracking.hide(responder)
    }
}

// MARK: - View Extension
@available(iOS 13.0, *)
public extension View {
    /// 添加页面埋点追踪
    /// - Parameter trackable: 遵循 GLPageTrackable 协议的对象
    /// - Returns: 添加了埋点追踪的视图
    func trackPageView(_ trackable: GLPageTrackable) -> some View {
        modifier(PageTrackingModifier(trackable: trackable))
    }
}

// MARK: - GLAPageTrackType Extension
@available(iOS 13.0, *)
public extension GLAPageTrackType {
    var suffix: String? {
        switch self {
        case .none:
            return nil
        case .exposure:
            return "exposure"
        case .click:
            return "click"
        case .close:
            return "close"
        case .open:
            return "open"
        case .hide:
            return "hide"
        case .scroll:
            return "scroll"
        case .scrolltobottom:
            return "scrolltobottom"
        }
    }
} 


private class SwiftUITrackingHolding: NSObject {
    static let shared = SwiftUITrackingHolding()

    private var trackingResponders: [SwitUITrackingBridgeResponder] = []

    private let maxCount: Int = 100

    func getBridgeResponder(_ pageName: String) -> SwitUITrackingBridgeResponder {
        if let responder = trackingResponders.reversed().first(where: { $0.pageName == pageName }) {
            return responder
        }

        let responder = createBridgeResponder(pageName)
        trackingResponders.append(responder)
        if trackingResponders.count > maxCount {
            trackingResponders.removeFirst()
        }
        return responder
    }

    func createBridgeResponder(_ pageName: String) -> SwitUITrackingBridgeResponder {
        return SwitUITrackingBridgeResponder(pageName: pageName)
    }
}


private class SwitUITrackingBridgeResponder: UIResponder, GLAPageProtocol {
    let _pageName: String
    var pageName: String? {
        _pageName
    }

    var _pageParams: [String: Any]? = nil
    var pageParams: [String: Any]? {
        _pageParams
    }

    var _disableAutoTrack: Bool = false
    var disableAutoTrack: Bool {
        _disableAutoTrack
    }

    init(pageName: String) {
        self._pageName = pageName
        super.init()
    }
}
