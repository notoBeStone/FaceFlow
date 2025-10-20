//
//  CacheDebugger.swift
//  CacheDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import GLUtils
import GLDebugger
import GLWidget

@objc public class CacheDebugger: NSObject {

    @objc public static let shared = CacheDebugger()

    lazy var debuggerWindow: CacheDebuggerWindow = {
        let window = CacheDebuggerWindow()
        return window
    }()
}
