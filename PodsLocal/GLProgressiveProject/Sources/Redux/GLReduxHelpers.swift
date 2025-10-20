//
//  GLReduxHelpers.swift
//  Memoirai
//
//  Created by stephenwzl on 2025/2/28.
//

import Foundation
// MARK: - reducer helpers

/// 通过泛型过滤 action 类型，只处理特定类型的 action
/// 适用于绝大部分情况下的 reducer 生成
public func ActionReducer<S,A>(_ handler: @escaping (S, A) -> S) -> GLReducer<S> where S: GLState, A: GLAction {
    { state, action in
        if let action = action as? A {
            return handler(state, action)
        }
        return state
    }
}

// MARK: - middleware helpers

/// 非传递型中间件，使用者自行决定是否调用 next(action)
/// 通过泛型过滤 action 类型，只处理特定类型的 action
public func NonPassableMiddleWare<S, A>(_ handler: @escaping (GLStore<S>, GLDispatch, A) -> Void) -> GLMiddleware<S> where S:GLState, A:GLAction {
    { store in
        { next in
            { action in
                if let action = action as? A {
                    handler(store, next, action)
                } else {
                    next(action)
                }
            }
        }
    }
}

/// 传递型中间件，使用者处理 action 在被 reducer 处理后的流程
/// 适用于绝大部分情况下的中间件生成
/// 通过泛型过滤 action 类型，只处理特定类型的 action
public func PassableMiddleWare<S, A>(_ handler: @escaping (GLStore<S>, A) -> Void) -> GLMiddleware<S> where S:GLState, A:GLAction {
    { store in
        { next in
            { action in
                next(action)
                if let action = action as? A {
                    handler(store, action)
                }
            }
        }
    }
}

public protocol GLReduxPage {
    associatedtype PageState: GLReduxPageState
    var store: GLStore<PageState> { get }
    var state: PageState { get }
    
    @MainActor
    func dispatch(_ action: PageState.ActionType)
    
    @MainActor
    func dispatch(_ action: any GLAction)
}

public protocol GLReduxPageState: GLState {
    associatedtype ActionType: GLAction
    
    static func createState() -> Self
    
    static var reducer: GLReducer<Self> { get }
    
    static var tracingEffect: GLMiddleware<Self>? { get }
    
    static var navigationEffect: GLMiddleware<Self>? { get }
    
    static func makeStore(_ initialState: Self?) -> GLStore<Self>
}

public extension GLReduxPage {
    
    var state: PageState {
        store.state
    }
    
    @MainActor
    func dispatch(_ action: PageState.ActionType) {
        store.dispatch(action)
    }
    @MainActor
    func dispatch(_ action: any GLAction) {
        store.dispatch(action)
    }
}

public extension GLReduxPageState {
    static func makeStore(_ initialState: Self? = nil) -> GLStore<Self> {
        var middlewares: [GLMiddleware<Self>] = []
        if let tracingEffect {
            middlewares.append(tracingEffect)
        }
        if let navigationEffect {
            middlewares.append(navigationEffect)
        }
        return GLStore(initialState: initialState ?? createState(), reducer: reducer, middlewares: middlewares)
    }
}
