//
//  Navigator.swift
//  Memoirai
//
//  Created by stephenwzl on 2025/2/18.
//

import GLUtils
import GLWidget
import SwiftUI
import GLAnalyticsUI

@MainActor
class Navigator {
    private static let shared = Navigator()
    private init() {}
    /// 当前正在展示的 popup
    weak var popup: BasePopUpView?
    
    static func push<Content>(_ page: Content, animated: Bool = true, from: String? = nil) where Content: ComposablePageComponent {
        UIViewController.gl_top().navigationController?.pushViewController(AnyComposableHostingController(rootView: page), animated: animated)
    }
    
    static func pushReplace<Content>(_ page: Content, animated: Bool = true, from: String? = nil) where Content: ComposablePageComponent {
        var vcs = UIViewController.gl_top().navigationController?.viewControllers
        vcs = vcs?.dropLast()
        vcs?.append(AnyComposableHostingController(rootView: page))
        UIViewController.gl_top().navigationController?.setViewControllers(vcs ?? [], animated: animated)
    }
    
    static func present<Content>(_ page: Content, animated: Bool = true, from: String? = nil) where Content: ComposablePageComponent {
        let vc = UIViewController.gl_top().navigationController ?? UIViewController.gl_top()
        vc.present(AnyComposableHostingController(rootView: page), animated: animated)
    }
    
    @available(*, deprecated, renamed: "push(_:animated:from:)", message: "please use composable page component to push")
    static func push<Content>(_ page: Content, animated: Bool = true, from: String? = nil) where Content: View&GLSwiftUIPageTrackable {
        UIViewController.gl_top().navigationController?.pushViewController(GLCommonHostingController(page, from: from), animated: animated)
    }
    @available(*, deprecated, renamed: "pushReplace(_:animated:from:)", message: "please use composable page component to pushReplace")
    static func pushReplace<Content>(_ page: Content, animated: Bool = true, from: String? = nil) where Content: View&GLSwiftUIPageTrackable {
        var vcs = UIViewController.gl_top().navigationController?.viewControllers
        vcs = vcs?.dropLast()
        vcs?.append(GLCommonHostingController(page, from: from))
        UIViewController.gl_top().navigationController?.setViewControllers(vcs ?? [], animated: animated)
    }
    
    @available(*, deprecated, renamed: "present(_:animated:from:)", message: "please use composable page component to present")
    static func present<Content>(_ page: Content, animated: Bool = true, from: String? = nil) where Content: View&GLSwiftUIPageTrackable {
        let vc = UIViewController.gl_top().navigationController ?? UIViewController.gl_top()
        vc.present(GLCommonHostingController(page, from: from), animated: animated)
    }
    
    
    static func push(_ vc: UIViewController, animated: Bool = true) {
        UIViewController.gl_top().navigationController?.pushViewController(vc, animated: animated)
    }
    
    static func present(_ vc: UIViewController, animated: Bool = true) {
        let topVC = UIViewController.gl_top().navigationController ?? UIViewController.gl_top()
        topVC.present(vc, animated: true)
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
    
    static func showPopup<Content>(_ page: Content,
                                   animated: Bool =  true,
                                   targetHeight: CGFloat = ScreenHeight - StatusBarHeight,
                                   completion: (() -> Void)? = nil
    ) where Content: View&GLSwiftUIPageTrackable  {
        let popup = GLCommonHostingPopup(rootView: page, targetHeight: targetHeight)
        Self.shared.popup = popup
        popup.show(true, animated: animated) {
            completion?()
        }
    }
    
    static func dismissPopup(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let popup = Self.shared.popup else {
            return
        }
        popup.dismiss(animated: animated) {
            completion?()
        }
        Self.shared.popup = nil
    }
    
    static func reset<Content>(_ page: Content, withNavigation: Bool = true) where Content: View&GLSwiftUIPageTrackable {
        KeyWindow()?.rootViewController = BaseNavigationViewController(rootViewController: GLCommonHostingController(rootView: page))
    }
    
    static func reset<Content>(_ page: Content, from: String? = nil) where Content: ComposablePageComponent {
        KeyWindow()?.rootViewController = BaseNavigationViewController(rootViewController: AnyComposableHostingController(rootView: page))
    }
    
    static func reset(_ vc: UIViewController) {
        KeyWindow()?.rootViewController = vc
    }
}

protocol GLSwiftUIPageTrackable {
    var trackerPageName: String? { get }
    var trackerPageParams: [String : Any]? { get }
    
    func onFirstAppear()
    func onPageExit()
}

extension GLSwiftUIPageTrackable {
    func onFirstAppear() {
        debugPrint("on page first appear")
    }
    func onPageExit() {
        debugPrint("on page exit")
    }
}

class GLCommonHostingController<Content>: GLBaseHostingViewController<Content>, GLAPageProtocol where Content: View&GLSwiftUIPageTrackable {
    var pageName: String? {
        rootView.trackerPageName
    }
    var pageParams: [String : Any]? {
        rootView.trackerPageParams
    }
    
    convenience init(_ rootView: Content, from: String? = nil) {
        self.init(rootView: rootView, from: from)
        self.hidesBottomBarWhenPushed = true
    }
    
    var isFirstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            isFirstAppear = false
            rootView.onFirstAppear()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isBeingDismissed || self.isMovingFromParent {
            rootView.onPageExit()
        }
    }
}

class GLCommonHostingPopup<Content>: BasePopUpView, GLAPageProtocol where Content: View&GLSwiftUIPageTrackable {
    public var rootView: Content
    private var targetHeight: CGFloat
    var pageName: String? {
        rootView.trackerPageName
    }
    var pageParams: [String : Any]? {
        rootView.trackerPageParams
    }
    
    init(rootView: Content, targetHeight: CGFloat = ScreenHeight - StatusBarHeight) {
        self.rootView = rootView
        self.targetHeight = targetHeight
        super.init()
        setupUI()
    }
    
    private func setupUI() {
        let hostingController = GLHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        contentView.addSwiftUI(viewController: hostingController) { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.height.equalTo(targetHeight)
        }
    }
    
    override var shouldResponseToKeyboard: Bool {
        true
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func show(in view: UIView? = nil, _ shown: Bool, animated: Bool, completion: @escaping () -> ()) {
        super.show(in: view, shown, animated: animated, completion: completion)
        trackingShow()
    }
    
    override func dismiss(animated: Bool, completion: @escaping () -> ()) {
        super.dismiss(animated: animated, completion: completion)
        trackingHide()
    }
}
