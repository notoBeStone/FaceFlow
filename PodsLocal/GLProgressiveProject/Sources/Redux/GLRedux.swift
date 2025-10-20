/**
    This is a simple redux store implementation.
    Created by AI
    2025-02-17
**/

import Foundation
import SwiftUI
import Combine

// MARK: - Action Protocol
public protocol GLAction {}

// MARK: - State Protocol
public protocol GLState {}

// MARK: - Reducer Type
public typealias GLReducer<S: GLState> = (S, GLAction) -> S

// MARK: - Async Action Type
public struct GLAsyncAction<StateType: GLState> {
    let execute: (GLStore<StateType>) async -> Void
    public init(execute: @escaping (GLStore<StateType>) async -> Void) {
        self.execute = execute
    }
}

extension GLAsyncAction: GLAction {}

// MARK: - Middleware Type
public typealias GLMiddleware<S: GLState> = (GLStore<S>) -> (@escaping GLDispatch) -> GLDispatch
public typealias GLDispatch = (GLAction) -> Void

// MARK: - Store
public final class GLStore<S: GLState>: ObservableObject, @unchecked Sendable {
    @Published public private(set) var state: S
    private let reducer: GLReducer<S>
    private var middlewares: [GLMiddleware<S>] = []
    
    // 保存关联对象的字典
    private var associatedObjects = [String: AnyObject]()
    public var cancellables: Set<AnyCancellable> = []
    
    public init(initialState: S, reducer: @escaping GLReducer<S>, middlewares: [GLMiddleware<S>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }
    
    private var dispatcher: GLDispatch {
        let initial: GLDispatch = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case let asyncAction as GLAsyncAction<S>:
                Task {
                    await asyncAction.execute(self)
                }
            default:
                self.state = self.reducer(self.state, action)
            }
        }
        
        return middlewares.reversed().reduce(initial) { dispatcher, middleware in
            middleware(self)(dispatcher)
        }
    }
    
    @MainActor
    public func dispatch(_ action: GLAction) {
        dispatcher(action)
    }
    
    public func addMiddleware(_ middleware: @escaping GLMiddleware<S>) {
        middlewares.append(middleware)
    }
    
    // 存储和获取关联对象的方法
    public func storeObject(_ object: AnyObject, forKey key: String? = nil) {
        let objectKey = key ?? String(describing: type(of: object))
        associatedObjects[objectKey] = object
    }
    
    public func getObject<T: AnyObject>(forKey key: String? = nil) -> T? {
        let objectKey = key ?? String(describing: T.self)
        return associatedObjects[objectKey] as? T
    }
    
    public func removeObject(forKey key: String) {
        associatedObjects.removeValue(forKey: key)
    }
    
    deinit {
        // 在 store 销毁时清理所有关联对象
        associatedObjects.removeAll()
    }
}

// MARK: - Store View Helper
@propertyWrapper
public struct StoreState<S: GLState, Value>: DynamicProperty {
    @ObservedObject private var store: GLStore<S>
    private let keyPath: KeyPath<S, Value>
    
    public init(store: GLStore<S>, keyPath: KeyPath<S, Value>) {
        self.store = store
        self.keyPath = keyPath
    }
    
    public var wrappedValue: Value {
        store.state[keyPath: keyPath]
    }
    
    public var projectedValue: Binding<Value> {
        Binding(
            get: { store.state[keyPath: keyPath] },
            set: { _ in }
        )
    }
}
