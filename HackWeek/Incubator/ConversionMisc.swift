//
//  ConversionMisc.swift
//  AquaAI
//
//  Created by stephenwzl on 9/10/25.
//

import UIKit
import SwiftUI
import GLPurchaseUI
import GLMP
import GLCore
import GLConfig_Extension
import GLResource
import GLUtils
import AppConfig
import GLAccountExtension


@MainActor
protocol PaywallNotifierDelegate: NSObjectProtocol {
    func closeAction()
    func startAction(_ skuId: String, trialable: Bool)
    func termsOfUseAction()
    func privacyPolicyAction()
    func subscriptionAction()
    func restoreAction()
    func setCurrentSkus(skus: [String])
    
    var trialReminderEnabled: Bool { get set }
    func changeTo(on: Bool, completion: @escaping (_ granted: Bool) -> Void)
}

class PaywallNotifier {
    static let shared = PaywallNotifier()
    weak var delegate: PaywallNotifierDelegate?
    
    enum ShowVipAnimationType: Int {
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
    
    /// 显示付费墙
    /// - Parameters:
    ///   - from: 来源
    ///   - animationType: 动画类型, 默认是present, addChild 是添加到当前视图控制器
    /// - Example: PaywallNotifier.shared.showVip()
    func showVip(_ from: String = "", animationType: ShowVipAnimationType = .present) {
        let memo = GL().ABTesting_ValueForKey("conversion_page", activate: false) ?? ConversionConfig.defaultMemo
        _ = GL().PurchaseUI_Open(memo, historyVipMemo: ConversionConfig.historyMemo, isVipInHistory: GL().Account_GetVipInfo()?.isVipInHistory.boolValue ?? false, vc: UIViewController.gl_top(), type: animationType.rawType,
                                 languageString: GLLanguage.currentLanguage.fullName,
                                 languageCode: GLLanguage.currentLanguage.languageId,
                                 from: from, identifyCount: 0, originGroup: nil, group: nil, abtestingID: nil, extra: [:]) { _, _ in
            return ""
        }
    }
}


/// SwiftUI 实现转化页的基础 ViewController
/// 实现新的 memo需要新增 Vip[Memo]AViewController: BasicConversionController, 并标记 objc class
open class BasicConversionController: GLOCVipBaseViewController, PaywallNotifierDelegate {
    var trialReminderEnabled: Bool {
        get { trialReminderEnable }
        set { super.trialReminderEnable = newValue }
    }
    
    func changeTo(on: Bool, completion: @escaping (Bool) -> Void) {
        purchaseTrailReminderManager.changeTo(on: on, completion: completion)
    }
    
    let conversionObserver = ConversionEventObserver()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        PaywallNotifier.shared.delegate = self
        setupMainUI()
        view.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12.rpx)
            make.top.equalTo(StatusBarHeight)
        }
    }
    
    open func setupMainUI() {
        self.addSwiftUI(viewController: .init(rootView: RootViewWrapper(provider: TemplateConfig.conversionView).environmentObject(conversionObserver))) { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Lazy load
    @objc open lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: IsIPad ? 18 : 16, weight: .medium)
        button.setTitleColor(.gl_color(0xb4b4b4).withAlphaComponent(0.5), for: .normal)
        button.gl_enlargeEdge(10)
        button.rac_signal(for: .touchUpInside).subscribeNext {[weak self] _ in
            self?.closeAction()
        }
        return button
    }()
    
    open override func getCloseButton() -> UIButton? {
        self.cancelButton
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        conversionObserver.viewWillAppearEvent.send()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conversionObserver.viewDidAppearEvent.send()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        conversionObserver.viewWillDisappearEvent.send()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        conversionObserver.viewDidDisappearEvent.send()
    }
    
    open override func updateUI() {
        conversionObserver.updateUIEvent.send()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    deinit {
        PaywallNotifier.shared.delegate = nil
    }
    
    open override func pageSkuIds() -> [String] {
        availableSkus
    }
    
    var availableSkus: [String] = []
    func setCurrentSkus(skus: [String]) {
        availableSkus = skus
    }
    
    func closeAction() {
        super.trackingClose()
        super.cancel()
    }
    
    func startAction(_ skuId: String, trialable: Bool) {
        if trialable {
            let title = "2 days left on your trial"
            let body = "Your subscription will change from trial to \(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "") Premium soon. Explore more features now!"
            super.reminderBuy(withSkuId: skuId, offerId: nil, title: title, body: body)
        } else {
            super.buy(withSkuId: skuId)
        }
    }
    
    func termsOfUseAction() {
        super.openTermsOfUse()
    }
    
    func privacyPolicyAction() {
        super.openPrivacyPolicy()
    }
    
    func subscriptionAction() {
        GLMPTracking.tracking("vip_subscriptionurl_click")
        var url = GL().GLConfig_GetMainHost().appending("/static/SubscriptionTerms_AppStore.html")
        if isInJapan {
            url = GL().GLConfig_GetMainHost().appending("/static/Japan/SubscriptionTerms_AppStore.html")
        }
        guard let url = URL(string: url) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    func restoreAction() {
        super.restore()
    }
    
    var isInJapan: Bool {
        countryCode == "JP"
    }
    
    var countryCode: String {
        guard let code = Locale.current.regionCode else {
            return "US"
        }
        return code
    }
}
