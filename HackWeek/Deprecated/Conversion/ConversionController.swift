//
//  ConversionController.swift
//  AquaAI
//
//  Created by stephenwzl on 2025/6/9.
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

@objc(Vip9999AViewController)
open class ConversionController: GLOCVipBaseViewController, PaywallNotifierDelegate {
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
        button.setTitleColor(.gl_color(0xffffff).withAlphaComponent(0.6), for: .normal)
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


@objc(Vip9998AViewController)
class HistoryConversionController: ConversionController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.imageOrMain("vip_icon_cancel", for: self.classForCoder) ?? UIImage()
        self.cancelButton.setImage(image, for: .normal)
        self.cancelButton.setTitle(nil, for: .normal)
    }
    
    override func setupMainUI() {
        self.addSwiftUI(viewController: .init(rootView: RootViewWrapper(provider: HistoryVipConversionView().anyView).environmentObject(conversionObserver))) { make in
            make.edges.equalToSuperview()
        }
    }
    
}

@objc(Vip9997AViewController)
class Vip9997ConversionController: ConversionController {
    
    override func setupMainUI() {
        self.addSwiftUI(viewController: .init(rootView: RootViewWrapper(provider: TrialableVipConversionPage().anyView).environmentObject(conversionObserver))) { make in
            make.edges.equalToSuperview()
        }
    }
    
}

@objc(Vip9996AViewController)
class Vip9996ConversionController: ConversionController {
    override func setupMainUI() {
        
        self.addSwiftUI(viewController: .init(rootView: RootViewWrapper(provider: HistoryVipConversionView().anyView).environmentObject(conversionObserver))) { make in
            make.edges.equalToSuperview()
        }
    }
}
