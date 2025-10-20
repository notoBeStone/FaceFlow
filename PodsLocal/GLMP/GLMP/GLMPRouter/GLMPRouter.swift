//
//  AppRouter.swift
//  AINote
//
//  Created by user on 2024/5/30.
//

import UIKit
import GLUtils

public typealias GLMPRouterViewControllerFactory = (_ url: GLURLConvertible, _ deeplink: DeepLink?) -> GLMPRouterDeepLinkDelegate?

public typealias GLMPRouterHandlerFactory = (_ url: GLURLConvertible, _ deeplink: DeepLink?) -> Bool

//MARK: - OpenStyle Enum
public enum OpenStyle: Int {
    case push = 0
    case present
    case presentWrapNav
    case popup
}

public enum CloseStyle: Int {
    case pop
    case dismiss
}

//MARK: - DeepLink Model
public struct DeepLink {
    
    public let path: String
    
    public let from: String
    
    public let params: [String: Any?]
    
    public let openStyle: OpenStyle
    
    public let animated: Bool
    
    
    public init(path: String, from: String?, params: [String: Any?] = [:], openStyle: OpenStyle = .push, animated: Bool = true) {
        self.path = path
        self.from = from ?? ""
        self.params = params
        self.openStyle = openStyle
        self.animated = animated
    }
    
    public static func from(url: GLURLConvertible) -> DeepLink? {
        guard let Url = url.urlValue else {
            return nil
        }
        
        let parameters: [String: String] = Url.queryParameters
        
        let from: String = parameters["from"] ?? ""
        
        var openStyle: OpenStyle = .push
        if let styleInt =  parameters["openstyle"] as? Int, let style = OpenStyle(rawValue: styleInt) {
            openStyle = style
        }
        var animated: Bool = true
        if let animatedInt = parameters["animated"] as? Int {
            animated = animatedInt != 0
        }
        
        return DeepLink(path: Url.path, from: from, params: parameters, openStyle: openStyle, animated: animated)
    }

    public func toUrl(scheme: String, host: String) -> GLURLConvertible? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if path.hasPrefix("/") {
            components.path = path
        } else {
            components.path = "/" + path
        }
        
        //忽略参数
        var params: [String: String] = [:]
        if !from.isEmpty {
            params["from"] = from
        }
        
        params["openstyle"] = String(openStyle.rawValue)
        
        params["animated"] = animated ? "1" : "0"
        
        components.queryItems = params.compactMap { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
        return components.url
    }
}

//MARK: - GLMPRouterDataSource protocol
public protocol GLMPRouterDataSource: AnyObject {
    
    func supportSchemes() -> [String]
    
    func supportHosts() -> [String]
    
    func getWapperNavigationController() -> UINavigationController.Type
}


//MARK: - GLMPRouterDeepLinkDelegate protocol
public protocol GLMPRouterDeepLinkDelegate: UIViewController {
    var deeplink: DeepLink? { get set }
    
    init?(deeplink: DeepLink)
    
    func popOrDismissController(defaultType: CloseStyle, animated: Bool)
}

public extension GLMPRouterDeepLinkDelegate {
    func popOrDismissController(defaultType: CloseStyle, animated: Bool) {
        if let deeplink {
            switch deeplink.openStyle {
            case .push:
                self.navigationController?.popViewController(animated: animated)
            case .present:
                self.dismiss(animated: animated)
            case .presentWrapNav:
                self.dismiss(animated: animated)
            case .popup:
                self.dismiss(animated: animated)
            }
        } else {
            switch defaultType {
            case .pop:
                self.navigationController?.popViewController(animated: animated)
            case .dismiss:
                self.dismiss(animated: animated)
            }
        }
    }
    
    func popOrDismissControllerToRoot(defaultType: CloseStyle, animated: Bool, completion: (() -> Void)? = nil) {
        if let deeplink {
            switch deeplink.openStyle {
            case .push:
                self.navigationController?.popToRootViewController(animated: animated)
                completion?()
            case .present, .presentWrapNav, .popup:
                self.dismiss(animated: animated) {
                    completion?()
                }
            }
        } else {
            switch defaultType {
            case .pop:
                self.navigationController?.popToRootViewController(animated: animated)
                completion?()
            case .dismiss:
                self.dismiss(animated: animated) {
                    completion?()
                }
            }
        }
    }
}

//MARK: - GLMPRouter protocol
public class GLMPRouter {

    private static let `default` = GLMPRouter()
    
    private var router: GLRouter
    
    
    private weak var dataSource: GLMPRouterDataSource?
    
    private init() {
        self.router = GLRouter()
        self.router.delegate = self
    }
    
    //set data source
    public static func setDataSource(_ dataSource: GLMPRouterDataSource?) {
        GLMPRouter.default.dataSource = dataSource
    }
    
    /* https"//www.baidu.com/identify/normal?from=123
     * https://www.AINoteai.com/identify/normal?from=123
     * AINote://dl/identify/normal?from=123
     * 注册的path为：identify/normal
     */
    
    ///注册VC
    public static func register(_ path: String, factory: @escaping GLMPRouterViewControllerFactory) {
        let mpFactory: GLRouterViewControllerFactory = { (url, values, context) in
            guard let deeplink = context as? DeepLink else {
                return nil
            }
            let vc = factory(url, deeplink)
            return vc
            
        }
        GLMPRouter.default.router.register(path, mpFactory)
    }
    
    ///注册回调
    public static func handle(_ path: String, factory: @escaping GLMPRouterHandlerFactory) {
        
        let mpHandler: GLRouterHandlerFactory = { (url, values, context) in
            guard let deeplink = context as? DeepLink else {
                return false
            }
            return factory(url, deeplink)
        }
        
        GLMPRouter.default.router.handle(path, mpHandler)
    }
    
    ///获取VC
    static func viewController(for url: GLURLConvertible, context: Any? = nil) -> UIViewController? {
        return  GLMPRouter.default.router.viewController(for: url, context: context)
    }
    
    //内部跳转
    @discardableResult
    public static func open(_ deeplink: DeepLink) -> Bool {
        guard let supportSchemes = self.default.dataSource?.supportSchemes(), let scheme = supportSchemes.first else {
            assertionFailure("please set DataSource")
            return false
        }
        
        guard let supportHosts = self.default.dataSource?.supportHosts(), let host = supportHosts.first else {
            assertionFailure("please set DataSource")
            return false
        }

        guard let url = deeplink.toUrl(scheme: scheme, host: host) else {
            return false
        }
        
        return open(url, deeplink: deeplink)
    }
    
    //外部跳转方法
    @discardableResult
    public static func open(_ url: GLURLConvertible) -> Bool {
        
        guard let deeplink = DeepLink.from(url: url) else {
            return false
        }
    
        return open(url, deeplink: deeplink)
    }
    
    
    private static func open(_ url: GLURLConvertible, deeplink: DeepLink) -> Bool {
    
        guard checkUrlValid(url) else {
            return false
        }
        
        
        if GLMPRouter.default.router.open(url, context: deeplink) {
            return true
        }
        
        if let vc = GLMPRouter.default.router.viewController(for: url, context: deeplink) {
            switch deeplink.openStyle {
            case .push:
                GLMPRouter.default.router.push(vc, animated: deeplink.animated)
            case .present:
                GLMPRouter.default.router.present(vc, animated: deeplink.animated)
            case .presentWrapNav:
                GLMPRouter.default.router.present(vc, wrap: self.default.dataSource?.getWapperNavigationController(), animated: deeplink.animated)
            case .popup:
                GLMPRouter.default.router.present(vc, wrap: self.default.dataSource?.getWapperNavigationController(), animated: false)
            }
            return true
        }
        
        return false
    }
    
    private static func checkUrlValid(_ url: GLURLConvertible) -> Bool {
        guard let urlValue = url.urlValue, let scheme = urlValue.scheme, let host = urlValue.host else {
            return false
        }
        
        if let supportSchemes = self.default.dataSource?.supportSchemes(), !supportSchemes.contains(scheme) {
            return false
        }
        
        if let supportHosts = self.default.dataSource?.supportHosts(), !supportHosts.contains(host) {
            return false
        }
        
        return true
    }

}

extension GLMPRouter: GLRouterNavigatorDelegate {
    
    public func shouldPush(viewController: UIViewController, from: GLNavigationControllerType) -> Bool {
        return true
    }


    public func shouldPresent(viewController: UIViewController, from: GLViewControllerType) -> Bool {
        return true
    }
}
