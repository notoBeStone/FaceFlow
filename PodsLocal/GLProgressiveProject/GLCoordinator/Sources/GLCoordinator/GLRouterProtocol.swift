//
//  GLRouterProtocol.swift
//  AINote
//
//  Created by user on 2024/4/22.
//

import UIKit


public protocol GLNavigationControllerType: AnyObject {
  func pushViewController(_ viewController: UIViewController, animated: Bool)
}

public protocol GLViewControllerType: AnyObject {
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension UINavigationController: @preconcurrency GLNavigationControllerType {}
extension UIViewController: @preconcurrency GLViewControllerType {}

@MainActor
public protocol GLRouterNavigatorDelegate: AnyObject {
  /// Returns whether the navigator should push the view controller or not. It returns `true` for
  /// default.
  func shouldPush(viewController: UIViewController, from: GLNavigationControllerType) -> Bool

  /// Returns whether the navigator should present the view controller or not. It returns `true`
  /// for default.
  func shouldPresent(viewController: UIViewController, from: GLViewControllerType) -> Bool
}

extension  GLRouterNavigatorDelegate {
  public func shouldPush(viewController: UIViewController, from: GLNavigationControllerType) -> Bool {
    return true
  }

  public func shouldPresent(viewController: UIViewController, from: GLViewControllerType) -> Bool {
    return true
  }
}


public protocol GLRouterProtocol: AnyObject {
    
    var delegate: GLRouterNavigatorDelegate? { get set }

    func register(_ path: String, _ factory: @escaping GLRouterViewControllerFactory)
    func handle(_ path: String, _ factory: @escaping GLRouterHandlerFactory)

    func viewController(for url: GLURLConvertible, context: Any?) -> UIViewController?
    func handler(for url: GLURLConvertible, context: Any?) -> GLRouterHandlerFactory?

    @discardableResult
    func push(_ url: GLURLConvertible, context: Any?, from: GLNavigationControllerType?, animated: Bool) -> UIViewController?

    @discardableResult
    func push(_ viewController: UIViewController, from: GLNavigationControllerType?, animated: Bool) -> UIViewController?

    @discardableResult
    func present(_ url: GLURLConvertible, context: Any?, wrap: UINavigationController.Type?, from: GLViewControllerType?, animated: Bool, completion: (() -> Void)?) -> UIViewController?

    @discardableResult
    func present(_ viewController: UIViewController, wrap: UINavigationController.Type?, from: GLViewControllerType?, animated: Bool, completion: (() -> Void)?) -> UIViewController?

    @discardableResult
    func open(_ url: GLURLConvertible, context: Any?) -> Bool
    
}


public extension GLRouterProtocol {
    
    func viewController(for url: GLURLConvertible, context: Any? = nil) -> UIViewController? {
        return self.viewController(for: url, context: context)
    }
    
    func handler(for url: GLURLConvertible, context: Any? = nil) -> GLRouterHandlerFactory? {
        return self.handler(for: url, context: context)
    }
    
    
    @discardableResult
    func push(_ path: String, context: Any? = nil, from: GLNavigationControllerType? = nil, animated: Bool = true) -> UIViewController? {
      return self.push(path, context: context, from: from, animated: animated)
    }
    
    
    @discardableResult
    func present(_  url: GLURLConvertible, context: Any? = nil, wrap: UINavigationController.Type? = nil, from: GLViewControllerType? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> UIViewController? {
      return self.present(url, context: context, wrap: wrap, from: from, animated: animated, completion: completion)
    }

    @discardableResult
    func open(_ url: GLURLConvertible, context: Any? = nil) -> Bool {
      return self.open(url, context: context)
    }
}
