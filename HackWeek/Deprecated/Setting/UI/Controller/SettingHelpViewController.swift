//
//  SettingHelpViewController.swift
//  PictureProjectSettingUI
//
//  Created by Martin on 2022/6/17.
//

import AppRepository
import DGMessageAPI
import GLAccountUIExtension
import GLAnalyticsUI
import GLCMSItemWebView
import GLConfig_Extension
import GLCore
import GLDatabase
import GLMP
import GLModules
import GLResource
import GLTrackingExtension
import GLUtils
import GLWidget
import SnapKit
import UIKit

private let DEEP_LINK_DELETE_ACCOUNT = "https://AINoteai.com/dl/DeleteAccount"
private let STRING_ARTICLE_FAQ = "article_faq"

class SettingHelpViewController: BaseViewController, GLAPageProtocol {
    public var pageName: String? = "settingshelp"
    
    var backUpdateBlock: (() -> Void)?
    
    var webView: GLCMSWebView?
    
    override func setNavigationView() {
        super.setNavigationView()
        self.navigationView.addLeftItem(self.backButton)
        self.navigationView.title = GLMPLanguage.text_help
    }
    
    @MainActor
    override func setUI() {
        super.setUI()
        
        Task {
            GLToast.showLoading()
            let url = await requestHelpUrl()
            if let url {
                GLToast.dismiss()
                DispatchQueue.main.async {
                    self.setupUI(url)
                }
            } else {
                GLToast.showError(GLMPLanguage.error_text_internal_error)
            }
        }
    }
    
    func setupUI(_ url: String) {
        setupWebView(url)
        
        guard let webView else { return }
        
        view.addSubview(webView)
        view.addSubview(bottomBgView)
        
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.navigationView.snp.bottom)
            make.bottom.equalTo(bottomBgView.snp.top)
            
        }
        bottomBgView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setupWebView(_ url: String) {
        let webView = GLCMSWebView(urlString: url)
        webView.cmsDelegate = self
        webView.loadCompletion = { [weak self] finish in
            self?.bottomBgView.isHidden = !finish
        }
        webView.backgroundColor = UIColor.gW
        webView.isOpaque = false
        self.webView = webView
    }
    
    override func backButtonClick() {
        super.backButtonClick()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Lazy load
    private lazy var bottomBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gW
        view.isHidden = true
        view.layer.shadowColor = UIColor.gl_color(0x000000, alpha: 0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 1
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(IsIPhone5 ? 290 : 340)
            make.centerX.equalToSuperview()
            make.height.equalTo(46)
            make.bottom.equalToSuperview().inset(IPhoneXBottomHeight + 24)
        }
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.medium(18)
        button.setTitle(GLMPLanguage.text_contact_us, for: .normal)
        button.setTitleColor(UIColor.gW, for: .normal)
        button.gl_cornerRadius = 23
        button.addTarget(self, action: #selector(consultUsAction), for: .touchUpInside)
        button.backgroundColor = UIColor.themeColor
        return button
    }()
}


// MARK: - Private Method
extension SettingHelpViewController {
    func requestHelpUrl() async -> String? {
        // 由于缺少下面六门语言对应的链接，因此当选择的是这六门语言的时候，请求英文的链接
//        let languageCode: LanguageCode
//        switch GLMPAppUtil.languageCode {
//        case .malay, .swedish, .polish, .chinese, .indonesian, .thai:
//            languageCode = .english
//        default:
//            languageCode = GLMPAppUtil.languageCode
//        }
//        
//        let staticContentRes = await CmsApis.requestCmsStaticContentMessage(
//            contentType: STRING_ARTICLE_FAQ,
//            languageCode: languageCode
//        )
//        
//        guard let jsonString = staticContentRes.data?.content,
//              let jsonData = jsonString.data(using: .utf8),
//              let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]]
//        else {
//            return nil
//        }
//        
//        for item in jsonArray {
//            if let uid = item["uid"] as? String,
//               uid == "no9t35hq",
//               let url = item["url"] as? String,
//               !url.isEmpty
//            {
//                let urlWithParam = url + "?from=app"
//                return urlWithParam
//            }
//        }
        return nil
    }
}


// MARK: - Action
extension SettingHelpViewController {
    @objc private func consultUsAction() {
        self.gl_track(type: .click, name: "contactus")
        GLMPRouter.open(DeepLinks.contactUsDeepLink(from: "help"))
    }
}


// MARK: - Delegate
extension SettingHelpViewController: GLCMSWebViewDelegate {
    // TODO: - JS
    // func cmsAction(_ actionName: String, parameter: [AnyHashable: Any]?) {
    //     if actionName == "deleteAccount" {
    //         self.deleteAction()
    //     }
    // }
    
    func interceptURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString
        
        // 处理邮件链接
        if urlString.starts(with: "mailto:") {
            if let mailURL = URL(string: urlString) {
                UIApplication.shared.open(mailURL)
            }
            return true
        }
        
        // 处理删除账号深链接
        if urlString == DEEP_LINK_DELETE_ACCOUNT {
            self.deleteAction()
            return true
        }
        
        // 其他链接由 webview 处理
        return false
    }
    
    private func deleteAction() {
        if let vc = GL().AccountUI_DeleteAccountController(actionBlock: { type, controller in
            switch type {
            case .loginOrSignUp: break
            case .knowledgeLevel: break
            case .deleteAccount:
                GLToast.dismiss()
                self.deleteAccount()
                controller.navigationController?.popViewController(animated: true)
            case .unsubscribe:
                controller.navigationController?.popViewController(animated: true)
            case .refund:
                break
            }
        }) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func deleteAccount() {
        UserCoreDataManager.shared.removeUserCoreData()
        
        GL().WebImage_ClearCache { [weak self] in
            self?.backUpdateBlock?()
        }
        GLMPAccount.setAccessToken(nil)
        
        GLMPAccount.userInitialise { _ in
            NotificationCenter.default.post(name: .init(rawValue: GLMediator.kUserDeleteNotification), object: nil)
        }
    }
}
