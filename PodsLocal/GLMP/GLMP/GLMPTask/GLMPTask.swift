//
//  GLMPTask.swift
//  GLMP
//
//  Created by xie.longyan on 2024/7/4.
//

import Foundation

public class GLMPTask<T> {
    private var task: Task<T, Never>?
    
    public var value: T? {
        get async {
            return await task?.value
        }
    }
    public private(set) var syncValue: T?
    public private(set) var isCompleted: Bool = false

    public init(_ operation: @escaping () async -> T) {
        self.task = Task {
            let result = await operation()
            self.syncValue = result
            self.isCompleted = true
            return result
        }
    }
}
