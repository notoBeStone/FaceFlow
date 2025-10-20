import Combine
import SwiftUI

// MARK: - 核心组件定义

// "特性"(Feature)的核心协议 - TCA风格
public protocol GLFeature {
    // 定义状态类型
    associatedtype State: Equatable
    // 定义动作类型
    associatedtype Action
    
    // 状态转换逻辑 - Reducer
    static func reduce(state: inout State, action: Action) -> [GLEffect<Action>]
    
    // 可选：状态初始化
    static func initialState() -> State
}

public extension GLFeature {
    static func initialState() -> State {
        fatalError("You should implement state creating manually")
    }
}

// 副作用类型 - 类似于TCA的Effect
public struct GLEffect<Action> {
    let run: (@escaping (Action) -> Void) -> Void
    
    public init(run: @escaping (@escaping (Action) -> Void) -> Void) {
        self.run = run
    }
    
    // 创建空效果
    public static var none: GLEffect {
        GLEffect { _ in }
    }
    
    // 创建立即执行的效果
    public static func fire(_ action: Action) -> GLEffect {
        GLEffect { dispatch in
            dispatch(action)
        }
    }
    
    // 从异步操作创建效果
    public static func future(_ operation: @escaping () async -> Action) -> GLEffect {
        GLEffect { dispatch in
            Task {
                let action = await operation()
                dispatch(action)
            }
        }
    }
    
    // 合并多个效果
    public static func merge(_ effects: [GLEffect<Action>]) -> GLEffect<Action> {
        GLEffect { dispatch in
            for effect in effects {
                effect.run(dispatch)
            }
        }
    }
    
    // 将效果映射到另一个动作类型
    public func map<B>(_ transform: @escaping (Action) -> B) -> GLEffect<B> {
        GLEffect<B> { dispatch in
            self.run { action in
                dispatch(transform(action))
            }
        }
    }
}

// MARK: - Store 实现

// Store 类 - 管理状态和处理动作
public final class GLFeatureStore<Feature: GLFeature>: ObservableObject {
    @Published public private(set) var state: Feature.State
    public var effectCancellables: Set<AnyCancellable> = []
    
    public init(initialState: Feature.State? = nil) {
        self.state = initialState ?? Feature.initialState()
    }
    
    // 派发动作
    @MainActor
    public func send(_ action: Feature.Action) {
        // 应用reducer
        let effects = Feature.reduce(state: &state, action: action)
        
        // 处理副作用
        for effect in effects {
            effect.run { [weak self] action in
                Task { @MainActor in
                    self?.send(action)
                }
            }
        }
    }
    
    // 绑定到特定状态属性的帮助方法
    public func binding<Value>(
        keyPath: WritableKeyPath<Feature.State, Value>,
        toAction: @escaping (Value) -> Feature.Action
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                Task { @MainActor in
                    self.send(toAction(newValue))
                }
            }
        )
    }
}

// MARK: - 视图绑定辅助工具

// 观察特定状态属性的属性包装器
@propertyWrapper
public struct GLViewState<Feature: GLFeature, Value: Equatable>: DynamicProperty {
    @ObservedObject private var store: GLFeatureStore<Feature>
    private let keyPath: KeyPath<Feature.State, Value>
    
    public init(store: GLFeatureStore<Feature>, keyPath: KeyPath<Feature.State, Value>) {
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

// 一个辅助协议，简化视图中的Store使用
public protocol GLFeatureView: View {
    associatedtype FeatureType: GLFeature
    var store: GLFeatureStore<FeatureType> { get }
}

// MARK: - 组合辅助工具

// 特性组合辅助方法
public enum GLCombine {
    // 将子特性组合到父特性
    public static func feature<ParentState, ParentAction, ChildState, ChildAction>(
        state toChildState: WritableKeyPath<ParentState, ChildState>,
        action toChildAction: @escaping (ChildAction) -> ParentAction,
        fromChildAction: @escaping (ParentAction) -> ChildAction?,
        reducer: @escaping (inout ChildState, ChildAction) -> [GLEffect<ChildAction>]
    ) -> (inout ParentState, ParentAction) -> [GLEffect<ParentAction>] {
        return { parentState, parentAction in
            if let childAction = fromChildAction(parentAction) {
                let effects = reducer(&parentState[keyPath: toChildState], childAction)
                return effects.map { effect in
                    effect.map(toChildAction)
                }
            }
            return []
        }
    }
    
    // 合并多个reducer
    public static func reducers<State, Action>(
        _ reducers: (inout State, Action) -> [GLEffect<Action>]...
    ) -> (inout State, Action) -> [GLEffect<Action>] {
        return { state, action in
            let effects = reducers.flatMap { $0(&state, action) }
            return effects
        }
    }
}

// 辅助方法 - 用于从异步操作创建效果
public extension GLEffect {
    static func task(
        priority: TaskPriority = .userInitiated,
        operation: @escaping () async -> Action?
    ) -> GLEffect {
        GLEffect { dispatch in
            Task(priority: priority) {
                if let action = await operation() {
                    dispatch(action)
                }
            }
        }
    }
    
    static func fireAndForget(
        _ operation: @escaping () async -> Void
    ) -> GLEffect {
        GLEffect { _ in
            Task {
                await operation()
            }
        }
    }
}

// 1. 首先创建一个 GLViewStore 类，它是对 GLFeatureStore 的包装
public final class GLViewStore<Feature: GLFeature, ViewState: Equatable>: ObservableObject {
    @Published public private(set) var viewState: ViewState
    private let store: GLFeatureStore<Feature>
    private let toViewState: (Feature.State) -> ViewState
    private var cancellable: AnyCancellable?
    
    public init(
        store: GLFeatureStore<Feature>,
        toViewState: @escaping (Feature.State) -> ViewState
    ) {
        self.store = store
        self.toViewState = toViewState
        self.viewState = toViewState(store.state)
        
        // 订阅原始 store
        cancellable = store.$state
            .map(toViewState)
            .removeDuplicates()  // 只有当转换后的状态变化时才更新
            .assign(to: \.viewState, on: self)
    }
    
    // 方便发送 Action
    @MainActor
    public func send(_ action: Feature.Action) {
        store.send(action)
    }
}

// 2. 创建一个 WithGLViewStore 视图结构体
public struct WithGLViewStore<Feature: GLFeature, ViewState: Equatable, Content: View>: View {
    @ObservedObject private var viewStore: GLViewStore<Feature, ViewState>
    private let content: (ViewState, @escaping (Feature.Action) -> Void) -> Content
    
    public init(
        store: GLFeatureStore<Feature>,
        toViewState: @escaping (Feature.State) -> ViewState,
        @ViewBuilder content: @escaping (ViewState, @escaping (Feature.Action) -> Void) -> Content
    ) {
        self.viewStore = GLViewStore(store: store, toViewState: toViewState)
        self.content = content
    }
    
    public var body: some View {
        content(viewStore.viewState) { action in
            viewStore.send(action)
        }
    }
}

// 3. 提供便捷扩展方法
public extension GLFeatureView {
    func withViewStore<ViewState: Equatable, Content: View>(
        toViewState: @escaping (FeatureType.State) -> ViewState,
        @ViewBuilder content: @escaping (ViewState, @escaping (FeatureType.Action) -> Void) -> Content
    ) -> some View {
        WithGLViewStore(
            store: self.store,
            toViewState: toViewState,
            content: content
        )
    }
} 
