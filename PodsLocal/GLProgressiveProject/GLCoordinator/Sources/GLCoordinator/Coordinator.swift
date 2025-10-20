//
//  GLCoordinator.swift
//  KnitAI
//
//  Created by stephenwzl on 2024/12/19.
//

import UIKit
import SwiftUI

@MainActor
public final class Coordinator {
    private static let shared = Coordinator()
    private init() {}
    private var destinations: [GLDestination] = []
    
    public class func register(@GLCoordinatorBuilder destinations: () -> [GLDestination]) {
        shared.destinations = destinations()
        for destination in shared.destinations {
            destination.register()
        }
    }
    
    public class func setResetRootDestination(_ destination: GLDestination? = nil) {
        var vc: UIViewController?
        if  let destination {
            vc = destination.action(DeepLink(path: destination.destination, from: nil))
        } else if let destination = shared.destinations.first(where: { $0.destination == GLDestination.rootDestinationName }) {
            vc = destination.action(DeepLink(path: destination.destination, from: nil))
        }
        if let vc = vc, let window = KeyWindow() {
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
    }
    
}

@resultBuilder
public struct GLCoordinatorBuilder {
    public static func buildBlock(_ components: GLDestination...) -> [GLDestination] {
        components
    }
}

@MainActor
public struct GLDestination {
    fileprivate let destination: String
    fileprivate let action: (DeepLink) -> UIViewController&GLMPRouterDeepLinkDelegate
    
    public init(destination: String, action: @escaping (DeepLink) -> UIViewController & GLMPRouterDeepLinkDelegate) {
        self.destination = destination
        self.action = action
    }
    
    public init(destination: String, action: @escaping (DeepLink) -> any View) {
        self.destination = destination
        self.action = { deeplink in
            return GLCoordinateCommonDestionationController(deeplink: deeplink, contentView: action(deeplink))
        }
    }
    
    fileprivate func register() {
        GLMPRouter.register(destination) { url, deeplink in
            if let deeplink {
                return action(deeplink)
            } else {
                return nil
            }
        }
    }
}

extension GLDestination {
  public static let rootDestinationName = "/"
}

open class GLCoordinateBaseController: UIViewController {}

class GLCoordinateCommonDestionationController: GLCoordinateBaseController, GLMPRouterDeepLinkDelegate {
    var pageName: String? {
        _pageName
    }
    
    var pageParams: [String : Any]? {
        _pageParams
    }
    
    var deeplink: DeepLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            nav.view.backgroundColor = .black.withAlphaComponent(0.6)
            self.view.backgroundColor = .clear
        } else {
            self.view.backgroundColor = .black.withAlphaComponent(0.6)
        }
        self.view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: isPopup ? contentHeight : 0), // out of screen
            contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
        let viewController = _GLHostingController(rootView: AnyView(_contentView!))
        let swiftuiView = viewController.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(viewController)
        view.addSubview(swiftuiView)
        NSLayoutConstraint.activate([
            swiftuiView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swiftuiView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swiftuiView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: isPopup ? contentHeight : 0), // out of screen
            swiftuiView.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
        viewController.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstAppear || !isPopup {
            return
        }
        isFirstAppear = true
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private lazy var contentView: UIView = UIView()
    
    private let _pageName: String?
    private let _pageParams: [String: Any]?
    private var _contentView: (any View)?
    private var isPopup = false
    private var contentHeight: CGFloat = UIScreen.main.bounds.height
    private var isFirstAppear: Bool = true
    
    convenience init(deeplink: DeepLink, contentView: any View) {
        self.init(deeplink: deeplink)!
        self._contentView = contentView
        self.isPopup = deeplink.openStyle == .popup
        self.modalPresentationStyle = .overCurrentContext
        self.contentHeight = deeplink.params[GLDestinationParamKeys.contentHeight] as? CGFloat ??  UIScreen.main.bounds.height
    }
    
    required init?(deeplink: DeepLink) {
        self._pageName = deeplink.params[GLDestinationParamKeys.pageName] as? String
        self._pageParams = deeplink.params[GLDestinationParamKeys.pageParams] as? [String: Any]
        self.deeplink = deeplink
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct GLDestinationParamKeys {
    public static let pageName = "pageName"
    public static let pageParams = "pageParams"
    public static let contentHeight = "contentHeight"
}
