//
//  CommonWebViewController.swift
//  AINote
//
//  Created by user on 2024/7/15.
//

import UIKit
import GLUtils
import GLResource
import GLWebView
import GLAnalyticsUI
import GLTrackingExtension
import GLMP

class CommonWebViewController: BaseViewController, GLAPageProtocol, GLMPRouterDeepLinkDelegate {
    var pageName: String? {
        return _pageName ?? "commonwebview"
    }
    
    var deeplink: GLMP.DeepLink?
    
    required convenience init?(deeplink: GLMP.DeepLink) {
        guard let url = deeplink.params[ParamKeys.url] as? String else {
            return nil
        }
        let title = deeplink.params[ParamKeys.title] as? String
        let pageName = deeplink.params[ParamKeys.pageName] as? String
        let startParams = deeplink.params[ParamKeys.startParams] as? [String: Any]
        
        self.init(url:url , from: deeplink.from, title: title, pageName: pageName, startParams: startParams)
    }
    
    
    var url: String
    var startParams: [String: Any]?
    private let _pageName: String?
    
    init(url: String, from: String, title: String?, pageName: String?, startParams: [String : Any]?) {
        self.url = url
        self.startParams = startParams
        self._pageName = pageName
        super.init(from: from)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .g0
        
        webView.startupParams = startParams
        loadWebview()
    }
    
    override func setUI() {
        super.setUI()
        view.addSubview(webView)
    }
    
    override func setConstraint() {
        super.setConstraint()
        webView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
    
    override func setNavigationView() {
        super.setNavigationView()
        navigationView.backgroundColor = .g0
        navigationView.title = self.title
        navigationView.addLeftItem(backButton)
    }
    
    func loadWebview() {
        if let url = URL(string: self.url) {
            webView.load(URLRequest(url: url))
        }
    }
    
    //MARK: - Action
    
    override func backButtonClick() {
        gl_track(type: .click, name: "back")
        popOrDismissController(defaultType: .pop, animated: true)
    }
    
    //MARK: - Lazy
    lazy var webView: H5ContentWebView = {
        let view = H5Manager.shared.webview()
        view.scrollView.bounces = false
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.scrollView.showsVerticalScrollIndicator = false
        return view
    }()
    
}
