//
//  BaseViewController.swift
//  AINote
//
//  Created by 彭瑞淋 on 2022/9/29.
//

import UIKit
import GLUtils
import GLAnalyticsUI
import GLWidget
import SwiftUI
import Combine

open class BaseViewController: GLBaseViewController, CombineActionProtocol {
    var cancellables = Set<AnyCancellable>()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .g0
    }
    
    // MARK: - Request Error
    open func showRequestFailed() {
        self.gl_track(type: .click, name: "showrequestfailed")
    }
    
    // Override this methods
    open func retryRequest() {
        self.gl_track(type: .click, name: "retry")
//        self.errorView.view.removeFromSuperview()
    }
}


open class BaseHostingViewController<Content: View>: BaseViewController {
    public var rootView: Content
    public var navigationTitle: String?
    
    public init(rootView: Content, title: String? = nil, isUIKitNavigationHidden: Bool = true, from: String? = nil) {
        self.rootView = rootView
        self.navigationTitle = title
        super.init(from: from)
        self.modalPresentationStyle = .fullScreen
        self.isHiddenNavigationBar = isUIKitNavigationHidden
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setNavigationView() {
        super.setNavigationView()
        
        self.navigationView.title = self.navigationTitle
    }
    
    open override func setSwiftUIView() {
        super.setSwiftUIView()
        
        addSwiftUI(viewController: hostingController) { make in
            make.leading.trailing.bottom.equalToSuperview()
            if isHiddenNavigationBar {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(navigationView.snp.bottom)
            }
        }
    }
    
    public lazy var hostingController: GLHostingController = {
        let controller = GLHostingController(rootView: rootView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    public var hostingView: UIView {
        hostingController.view
    }
}
