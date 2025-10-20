//
//  RenewRetentionViewController.swift
//  AINote
//
//  Created by user on 2024/5/30.
//

import UIKit
import GLUtils
import GLWidget
import GLCore
import GLAnalyticsUI
import GLTrackingExtension
import GLPurchaseExtension

class RenewRetentionViewController: BaseViewController, GLAPageProtocol {

    var dismissClonse: (() -> Void)?
    private var hasBuySuccess = false;
    private var clickCount = 0;
    // 限制时间
    private let limitDay = Int(RenewRetentionManager.limitTime / (24 * 3600))
                               
    var pageName: String? {
        return "addvipequitypage"
    }
    
    var pageParams: [String : Any]? {
        let params: [String: Any] = [GLT_PARAM_FROM: from,
                                     GLT_PARAM_TIME: CFAbsoluteTimeGetCurrent() - beginTime,
                                     GLT_PARAM_TYPE: addEquityType.rawValue,
                                     GLT_PARAM_CODE: "\(limitDay)"
        ]
        
        return params
    }
    
    private var from: String {
        return fromPage ?? ""
    }
    private var complete:(() -> Void)
    private let addEquityType: RenewRetentionManager.RenewType
    // 起始时间
    private var beginTime: CFAbsoluteTime = 0
    // dismssAnimated
    private var dismssAnimated = true
    
    init(addEquityType: RenewRetentionManager.RenewType, from: String, complete: @escaping (() -> Void)) {
        self.complete = complete
        self.addEquityType = addEquityType
        super.init(from: from)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        // 记录起始时间
        self.beginTime = CFAbsoluteTimeGetCurrent()
        self.gl_track(type: .exposure, name: "bennefits")
        
        RenewRetentionManager.shownAction()
        view.backgroundColor = UIColor.gl_color(0x000000)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    //MARK: - configUI
    private func configUI() {
        guard let view = view else {
            return;
        }
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(equityView)
        equityView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(IsIPhoneX ? 38 : IsIPhone5 ? 24 : 30)
            make.trailing.equalToSuperview().inset(16)
            if IsIPhone5 {
                make.size.equalTo(CGSize.init(width: 24, height: 24))
            } else {
                make.size.equalTo(CGSize.init(width: 30, height: 30))
            }
        }
    }
    //MARK: - continiue Action
    private func continueAction() {
        clickCount = clickCount + 1;
        gl_track(type: .click, name: "buyvipbtn", parameters: [GLT_PARAM_COUNT: clickCount])
        // 可能请求出错啦
        if self.hasBuySuccess {
            self.updateToServer()
        } else {
            self.buyVipAction()
        }
    }
    private func buyVipAction() {
        GLToast.showLoading()
        GL().Purchase_PurchaseSubscription(sku: RenewRetentionManager.userSku ?? "") {[weak self] errorInfo, desc, result in
            let error = errorInfo.simpleError
            let succeed = (error == .succeed)
            if (succeed) {
                self?.hasBuySuccess = true
                self?.gl_track(type: .exposure, name: "buysuccess")
                self?.updateToServer()
            } else {
                GLToast.dismiss()
                self?.gl_track(type: .exposure, name: "buyfailed", parameters: [GLT_PARAM_VALUE: "\(error.rawValue)"])
            }
        }
    }
    
    private func updateToServer() {
        GLToast.showLoading()
        RenewRetentionManager.addVipRenewRights {[weak self] finish in
            self?.gl_track(type: .exposure, name: "sendserver", parameters: [GLT_PARAM_STATUS: finish.description, GLT_PARAM_VALUE: (self?.hasBuySuccess ?? false).description])
            RenewRetentionManager.isAddEquityUser = true
            GLToast.dismiss()
            if finish {
                self?.dismissAction()
            } else {
                // 不卡用户流程
                self?.dismissAction()
            }
        }
    }
    
    private func dismissAction() {
        self.dismiss(animated: false) {[weak self] in
            self?.dismissClonse?()
        }
    }
    
    // 关闭按钮Action
    @objc
    private func closeAction() {
        gl_track(type: .click, name: "giveupbtn")
        dismiss(animated: dismssAnimated) {[weak self] in
            self?.complete()
        }
    }
    //MARK: - lazy
    private lazy var bgView: UIView = {
        let view = UIView()
        view.gl_setGradientColors([UIColor.gl_color(0x090707), UIColor.gl_color(0x000000)], vertical: true)
        return view
    }()
    // closeBtn
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.isHidden = false
        btn.setImage(UIImage(named: "autorenew_close1_icon"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var equityView: RenewRetentionView = {
        let view = RenewRetentionView.init(addEquityType: addEquityType) {[weak self] in
            self?.gl_track(type: .click, name: "giveupbtn")
            self?.dismiss(animated: self?.dismssAnimated ?? false) {[weak self] in
                self?.complete()
            }
        } continiueClonse: {[weak self] in
            self?.continueAction()
        }
        
        view.termUseClonse = {[weak self] in
            guard let self = self else { return }
            self.gl_track(type: .click, name: "termsofuse")
            GL().Agreement_OpenCurrentTermsOfUse(controller: self)
        }
        
        view.privacyClonse = {[weak self] in
            guard let self = self else { return }
            self.gl_track(type: .click, name: "privacypolicy")
            GL().Agreement_OpenPrivacyPolicy(controller: self)
        }
        
        view.subClonse = {[weak self] in
            self?.gl_track(type: .click, name: "subscription")
            RenewRetentionManager.openSubscriptionAction()
        }
        
        return view
    }()

}
