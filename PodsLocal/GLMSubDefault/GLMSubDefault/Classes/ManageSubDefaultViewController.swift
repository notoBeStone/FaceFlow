//
//  ManageSubDefaultViewController.swift
//  GLMSubDefault
//
//  Created by user on 2023/10/20.
//

import Foundation
import GLUtils
import GLAnalyticsUI
import GLManageSubscriptionBase

@objc(ManageSubDefaultViewController)
public class ManageSubDefaultViewController: GLManageSubBaseViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        addLayouts()
        configUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Public
    
    //MARK: - UI
    private func configUI() {
        view.backgroundColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder)
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(vipInfoView)
        contentView.addSubview(descLabel)
        contentView.addSubview(noticeView)
        
        view.addSubview(closeBtn)
        view.addSubview(titleLabel)
        view.addSubview(bottomView)
    }
    
    private func addLayouts() {
        closeBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(9.rpt)
            make.top.equalToSuperview().offset(GLFrameSize3(1.0, -5, 1.0, 1.0).rpt + GLSafeTop)
            make.width.height.equalTo(44.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24.0.rpt)
            make.top.equalToSuperview().offset(GLFrameSize3(30.0, 24.0, 30.0, 30.0).rpt + GLSafeTop)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-GLSafeBottom)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20.rpt)
            make.bottom.equalTo(bottomView.snp.top).offset(40.0.rpt)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
        
        vipInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24.0.rpt)
            make.top.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24.0.rpt)
            make.top.equalTo(vipInfoView.snp.bottom).offset(20.0.rpt)
        }
        
        noticeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(descLabel.snp.bottom).offset(16.0.rpt)
            make.bottom.equalToSuperview().offset(-40.0.rpt)
        }
    }
    
    //MARK: - lazy
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.imageOrMain("glmsub_close", for: self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = MANAGESUBDEFAULT_TITLE.localizedOrMain(for: self.classForCoder)
        label.font = UIFont.bold(22.rpt)
        label.gl_lineHeight = 24.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack1, for: self.classForCoder)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var vipInfoView: ManageSubDefaultVipInfoView = {
        let view = ManageSubDefaultVipInfoView()
        view.config(withVipInfo: GL().Account_GetVipInfo())
        return view
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        label.text = MANAGESUBDEFAULT_DESC.localizedOrMain(for: self.classForCoder, appName)
        label.font = UIFont.medium(14.rpt)
        label.gl_lineHeight = 22.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var noticeView: ManageSubDefaultNoticeView = {
        let view = ManageSubDefaultNoticeView()
        view.config(withVipInfo: GL().Account_GetVipInfo())
        return view
    }()
    
    private lazy var bottomView: ManageSubDefaultBottomView = {
        let view = ManageSubDefaultBottomView()
        view.cancelBlock = { [weak self] in
            self?.cancelAction()
        }
        view.keepBlock = { [weak self] in
            self?.keepAction()
        }
        return view
    }()
}

//MARK: - Action
extension ManageSubDefaultViewController {
    @objc
    private func closeAction() {
        GLMSubEventUtil.eventName("return_to_member_center_a")

        didBack()
    }
    
    @objc
    private func cancelAction() {
        GLMSubEventUtil.eventName("cancel_subscription_a")

        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func keepAction() {
        GLMSubEventUtil.eventName("keep_my_plan_a")
        
        didBack()
    }
    
    private func didBack() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - GLAPageProtocol
extension ManageSubDefaultViewController: GLAPageProtocol {
    
    public var pageName: String? {
        return "managesubdefault"
    }
    
    public var pageParams: [String : Any]? {
        return nil
    }
}

