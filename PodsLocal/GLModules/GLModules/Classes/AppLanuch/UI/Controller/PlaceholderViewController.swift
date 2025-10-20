//
//  PlaceholderViewController.swift
//  AINote
//
//  Created by 彭瑞淋 on 2022/9/29.
//

import UIKit
import GLUtils
import SnapKit
import GLLottie
import GLMP
import SwiftUI

class PlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    private static var retryTimeInterval: TimeInterval = 10
    
    // MARK: - Config
    
    func configUI() {
        self.view.backgroundColor = UIColor(named: "mainBackgroundColor")
        self.view.gl_addSubviews([self.imageView])
        self.imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60.0)
        }
    }
    
    // MARK: - Lazy Load
    private lazy var imageView: UIImageView = {
        var iv = UIImageView.init(image: .init(named: "pic_start_up"))
        return iv
    }()
}

extension PlaceholderViewController: AppLaunchSplashProtocol {
    
    func showErrorUI(_ retry: @escaping () -> Void) {
        
        //失败重试
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.retryTimeInterval) {
            Self.retryTimeInterval = Self.retryTimeInterval + 5.0
            retry()
        }
        
    }

}
