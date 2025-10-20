//
//  TemplateWrapper.swift
//  SupplementID
//
//  Created by stephenwzl on 2025/6/10.
//

import SwiftUI
import UIKit
import GLUtils
import GLCore
import GLTrackingExtension
import GLAdjustExtension
import GLModules
import GLMP
import GLAdjust
import GLWidget
import GLPurchaseExtension

struct TemplateWrapper {
    static func leagacyFininshLaunchinng() {
//        if #available(iOS 18, *), IsIPad {
//            UIViewController.swizzleViewWillLayoutSubviews()
//        }
        
        AppLaunch.launch(with: CommonAppLaunch())
        _ = DeepLinks.shared
        BackgroundRefreshManager.shared.registerBackgroundTask()
    }

    static func leagacyDidRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
         PushTools.shared.registerForRemoteNotificationsWithDeviceToken(deviceToken)
        GL().Adjust_AppDidRegisterForRemoteNotifications(deviceToken: deviceToken)
    }

    static func leagacyDidEnterBackground() {
        BackgroundRefreshManager.shared.scheduleBackgroundRefresh()
    }

    static func leagacyHandleOpenUrl(url: URL) -> Bool {
       return DeeplinkHandleManager.shared.handleUrl(url)
    }

}

class TemplateHostingController<Content>: GLBaseHostingViewController<AnyView> where Content: View {
    var vcObserver: ViewControllerEventObserver?
    convenience init(_ rootView: Content, from: String? = nil) {
        let observer = ViewControllerEventObserver()
        self.init(rootView: AnyView(rootView.environmentObject(observer)), from: from)
        self.vcObserver = observer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.vcObserver?.viewDidLoadEvent.send()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vcObserver?.viewWillAppearEvent.send()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vcObserver?.viewDidAppearEvent.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vcObserver?.viewWillDisappearEvent.send()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        vcObserver?.viewDidDisappearEvent.send()
    }
    
}

struct TemplateNavigator {
    static func push<Content: View>(_ view: Content, from: String? = nil, animated: Bool = true) {
        let controller = TemplateHostingController(view, from: from)
        UIViewController.gl_top().navigationController?.pushViewController(controller, animated: animated)
    }

    static func present<Content: View>(_ view: Content, from: String? = nil, animated: Bool = true) {
        let controller = TemplateHostingController(view, from: from)
        UIViewController.gl_top().present(controller, animated: animated)
    }

    static func present(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        let topVC = UIViewController.gl_top().navigationController ?? UIViewController.gl_top()
        topVC.present(vc, animated: animated, completion: completion)
    }

    static func pushReplace<Content: View>(_ view: Content, from: String? = nil, animated: Bool = true) {
        let controller = TemplateHostingController(view, from: from)
        var vcs = UIViewController.gl_top().navigationController?.viewControllers
        vcs = vcs?.dropLast()
        vcs?.append(controller)
        UIViewController.gl_top().navigationController?.setViewControllers(vcs ?? [], animated: animated)
    }
    
    static func pop(_ animated: Bool = true) {
        UIViewController.gl_top().navigationController?.popViewController(animated: animated)
    }
    
    static func popAll(_ animated: Bool = true) {
        UIViewController.gl_top().navigationController?.popToRootViewController(animated: animated)
    }
    
    static func dismiss(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        UIViewController.gl_top().dismiss(animated: animated, completion: completion)
    }

    static func reset<Content: View>(_ view: Content) {
        let controller = TemplateHostingController(view)
        UIViewController.gl_top().navigationController?.setViewControllers([controller], animated: false)
    }
    
    /// deprecate in future
    static func navToSettings(_ from: String = "") {
        GLMPRouter.open(DeepLinks.settingsDeepLink(from: from))
    }
}

struct TemplateConsts {
    static var safeAreaEdges: UIEdgeInsets {
        Consts.safeAreas
    }
    
    static var isiPad: Bool {
        IsIPad
    }
    
    static var screenSize: (width: CGFloat, height: CGFloat) {
        (ScreenWidth, ScreenHeight)
    }
}


// MARK: - Default Implementations
extension ConversionSku.SkuPeriod {
    static func from(_ period: GLPurchaseExtension.SkuPeriod) -> Self {
        switch period {
            case .weekly:
                return .weekly
            case .monthly:
                return .monthly
            case .yearly:
                return .yearly
            case .seasonly:
                return .seasonly
            case .halfYearly:
                return .halfYearly
        }
    }
}

extension ConversionAPI {
    @MainActor
    static func enableCurrentSkus(_ skus: [String]) {
        PaywallNotifier.shared.delegate?.setCurrentSkus(skus: skus)
    }
    static func fetchSkuInfo(_ skuId: String) -> ConversionSku? {
        guard let product = GL().Purchase_FetchProductFromCache(skuId) else {
            return nil
        }
        guard let skuModel = GL().Purchase_GetSkuModel(forId: skuId) else {
            return nil
        }
        let trialDays = skuModel.toSubscriptionModel?.trailDays ?? 0
        let period: ConversionSku.SkuPeriod
        if let rawPeriod = skuModel.toSubscriptionModel?.period {
            period = .from(rawPeriod)
        } else {
            period = .none
        }
        return ConversionSku(skuId: skuId, trialDays: trialDays, period: period, product: product)
    }
    @MainActor
    static func showVip(from: String = "", animationType: PaywallNotifier.ShowVipAnimationType = .present) {
        PaywallNotifier.shared.showVip(from, animationType: animationType)
    }
    
    @MainActor
    static func closePage() {
        PaywallNotifier.shared.delegate?.closeAction()
    }
    
    @MainActor
    static func startPurchase(_ skuId: String, trialable: Bool) {
        PaywallNotifier.shared.delegate?.startAction(skuId, trialable: trialable)
    }
    
    @MainActor
    static func showTermsOfUse() {
        PaywallNotifier.shared.delegate?.termsOfUseAction()
    }
    
    @MainActor
    static func showSubscriptionTerms() {
        PaywallNotifier.shared.delegate?.subscriptionAction()
    }
    
    @MainActor
    static func showPrivacyPolicy() {
        PaywallNotifier.shared.delegate?.privacyPolicyAction()
    }
    
    @MainActor
    static func manageSubscription() {
        PaywallNotifier.shared.delegate?.subscriptionAction()
    }
    
    @MainActor
    static func restorePurchase() {
        PaywallNotifier.shared.delegate?.restoreAction()
    }
    
    @MainActor
    static var trialReminderEnabled: Bool {
        get { PaywallNotifier.shared.delegate?.trialReminderEnabled ?? false }
        set { PaywallNotifier.shared.delegate?.trialReminderEnabled = newValue }
    }
    
    @MainActor
    static func changeReminder(to enabled: Bool, completion: @escaping (_ granted: Bool) -> Void) {
        PaywallNotifier.shared.delegate?.changeTo(on: enabled, completion: completion)
    }
}

extension NavigatorAPI {
    static func push<Content: View>(_ view: Content, from: String? = nil, animated: Bool = true) {
        TemplateNavigator.push(view, from: from, animated: animated)
    }
    
    static func present<Content: View>(_ view: Content, from: String? = nil, animated: Bool = true) {
        TemplateNavigator.present(view, from: from, animated: animated)
    }
    
    static func present(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        let wrapped = BaseNavigationViewController(rootViewController: vc)
        wrapped.modalPresentationStyle = .custom
        TemplateNavigator.present(wrapped, animated: animated, completion: completion)
    }
    
    static func pushReplace<Content: View>(_ view: Content, from: String? = nil, animated: Bool = true) {
        TemplateNavigator.pushReplace(view, from: from, animated: animated)
    }
    
    static func pop(_ animated: Bool = true) {
        TemplateNavigator.pop(animated)
    }
    
    static func popAll(_ animated: Bool = true) {
        TemplateNavigator.popAll(animated)
    }
    
    static func dismiss(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        TemplateNavigator.dismiss(animated, completion: completion)
    }
    
    static func reset<Content: View>(_ view: Content) {
        TemplateNavigator.reset(view)
    }
    
    static func openSettings(_ from: String = "") {
        TemplateNavigator.navToSettings(from)
    }
}


extension MediaQueryAPI {
    static var safeArea: EdgeInsets {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return .init(top: 44, leading: 0, bottom: 32, trailing: 0)
        }
        let edges = TemplateConsts.safeAreaEdges
        return .init(top: edges.top, leading: edges.left, bottom: edges.bottom, trailing: edges.right)
    }
    
    static var isIPad: Bool {
        return TemplateConsts.isiPad
    }
    
    static var screenSize: (width: CGFloat, height: CGFloat) {
        return TemplateConsts.screenSize
    }
}

extension DebuggerAPI {
    static func showDebugMessage(_ message: String) {
#if DEBUG
        TemplateNavigator.present(TemplateHostingController(DebuggerView(message: message)), animated: false)
#endif
    }
}

extension S3API {
    static func upload(data: Data, fileExtension: String) async throws ->  String {
        return try await withCheckedThrowingContinuation { continuation in
            GLMPUpload.upload(data: data, uploadType: .common, fileType: .common(extension: fileExtension), imageFrom: .album) { url, itemId, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let url {
                    continuation.resume(returning: url)
                    return
                }
                continuation.resume(throwing: S3ErrorType.unknownError)
            }
        }
    }
}
