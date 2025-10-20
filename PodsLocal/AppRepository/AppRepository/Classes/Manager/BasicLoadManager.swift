//
//  BasicLoadManager.swift
//  AppRepository
//
//  Created by Martin on 2024/11/14.
//

import Foundation

public typealias BOOLCompletion = (Bool) -> Void

public class BasicLoadManager: ObservableObject {
    private var completions: [BOOLCompletion] = []
    
    // 返回值: 是否需要继续执行
    func append(completion: @escaping BOOLCompletion) -> Bool {
        lock.lock()
        defer {lock.unlock()}
        
        let ret = !self.completions.isEmpty
        self.completions.append(completion)
        return ret
    }
    
    func complete(_ succeed: Bool) {
        self.lock.lock()
        defer {self.lock.unlock()}
        
        self.completions.map {$0(succeed)}
        self.completions = []
    }
    
    // MARK: - Lazy load
    private lazy var lock = NSLock()
}
