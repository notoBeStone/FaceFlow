//
//  LocalNetworkPermission.swift
//  IOSProject
//
//  Created by Martin on 2023/6/25.
//

import UIKit
import GLUtils

class LocalNetworkPermission {
    private var completion: (()->())?
    
    init() {
        self.addObserver()
    }
    
    func requestNetworkingAuth(_ completion: @escaping ()->()) {
        self.completion = completion
        UIApplication.gl_openSettingURL()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) {[weak self] _ in
            self?.didBecomeActiveNotification()
        }
    }
    
    private func didBecomeActiveNotification() {
        let completion = self.completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion?()
        }
        self.completion = nil
    }
}
