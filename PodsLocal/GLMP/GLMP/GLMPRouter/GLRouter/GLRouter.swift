//
//  GLRouter.swift
//  AINote
//
//  Created by user on 2024/4/22.
//

import UIKit
import GLUtils


public typealias GLRouterViewControllerFactory = (_ url: GLURLConvertible, _ values: [String: Any], _ context: Any?) -> UIViewController?

public typealias GLRouterHandlerFactory = (_ url: GLURLConvertible, _ values: [String: Any], _ context: Any?) -> Bool

public typealias GLRouterHandler = () -> Bool

public class GLRouter: GLRouterProtocol {

    
    private var viewControllerFactories = [String: GLRouterViewControllerFactory]()
    private var handerFactories = [String: GLRouterHandlerFactory]()
    
    weak public var delegate: GLRouterNavigatorDelegate?
    
    public init() {}
    
    
    public func register(_ path: String, _ factory: @escaping GLRouterViewControllerFactory) {
        self.viewControllerFactories[path] = factory
    }
    
    public func handle(_ path: String, _ factory: @escaping GLRouterHandlerFactory) {
        self.handerFactories[path] = factory
    }
    
    public func viewController(for url: GLURLConvertible, context: Any? = nil) -> UIViewController? {
        guard let _ = url.urlValue else {
            return nil
        }
        guard let info = Self.getUrlPathQueryItems(url) else {
            return nil
        }
        
        guard let factory = self.viewControllerFactories[info.0] else {
            return nil
        }
    
        return factory(url, info.1, context)
    }
    
    
    public func handler(for url: GLURLConvertible, context: Any? = nil) -> GLRouterHandler? {
        
        guard let _ = url.urlValue else {
            return nil
        }
        
        guard let info = Self.getUrlPathQueryItems(url) else {
            return nil
        }
        
        guard let hander = self.handerFactories[info.0] else {
            return nil
        }
        return { hander(url, info.1, context) }
    }

    
    @discardableResult
    open func push(_ url: GLURLConvertible, 
                   context: Any? = nil,
                   from: GLNavigationControllerType? = nil,
                   animated: Bool = true) -> UIViewController? {
      guard let viewController = self.viewController(for: url, context: context) else { return nil }
      return self.push(viewController, from: from, animated: animated)
    }
    
    @discardableResult
    public func push(_ viewController: UIViewController, 
                     from: GLNavigationControllerType? = nil,
                     animated: Bool = true) -> UIViewController? {
        guard (viewController is UINavigationController) == false else { return nil }
        guard let navigationController = from ?? UIViewController.gl_top().navigationController else { return nil }
        guard self.delegate?.shouldPush(viewController: viewController, from: navigationController) != false else { return nil }
        navigationController.pushViewController(viewController, animated: animated)
        return viewController
    }
    
    
    
    
    @discardableResult
    open func present(_ url: GLURLConvertible, 
                      context: Any? = nil,
                      wrap: UINavigationController.Type? = nil,
                      from: GLViewControllerType? = nil,
                      animated: Bool = true,
                      completion: (() -> Void)? = nil) -> UIViewController? {
      guard let viewController = self.viewController(for: url, context: context) else { return nil }
      return self.present(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
    }
    
    @discardableResult
    public func present(_ viewController: UIViewController,
                        wrap: UINavigationController.Type? = nil,
                        from: GLViewControllerType? = nil,
                        animated: Bool = true,
                        completion: (() -> Void)? = nil) -> UIViewController? {
        
        let fromViewController = from ?? UIViewController.gl_top()
        
        let viewControllerToPresent: UIViewController
        if let navigationControllerClass = wrap, (viewController is UINavigationController) == false {
            viewControllerToPresent = navigationControllerClass.init(rootViewController: viewController)
            viewControllerToPresent.modalPresentationStyle = viewController.modalPresentationStyle
        } else {
            viewControllerToPresent = viewController
        }
        
        guard self.delegate?.shouldPresent(viewController: viewController, from: fromViewController) != false else { return nil }
        fromViewController.present(viewControllerToPresent, animated: animated, completion: completion)
        return viewController
    }
    
    
    
    
    @discardableResult
    open func open(_ url: GLURLConvertible, context: Any? = nil) -> Bool {
      guard let handler = self.handler(for: url, context: context) else { return false }
      return handler()
    }
}


extension GLRouter {
    
    private static func getUrlPathQueryItems(_ url: GLURLConvertible) -> (String, [String: String])? {
        guard let urlValue = url.urlValue else {
            return nil
        }
        let separator = "/"
        
        let path = urlValue.pathComponents.joined(separator: separator).trimmingCharacters(in: CharacterSet(charactersIn:separator))
        
        var params: [String: String] = [:]
        if let queryItems = URLComponents(string: urlValue.absoluteString)?.queryItems {
            queryItems.forEach { item in
                if let value = item.value {
                    params[item.name] = value
                }
            }
        }
        return (path, params)
        
    }
}
