//
//  VideoView.swift
//  Vip27534
//
//  Created by Martin on 2024/4/7.
//

import UIKit
import GLUtils

class VideoView: UIView {
    init() {
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.gl_addSubviews([self.videoView, self.gradientView])
        
        self.videoView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.equalTo(self.videoView.snp.width).multipliedBy(1080.0/886.0)
            make.bottom.equalToSuperview().offset(2.0)
            
            if IsIPad {
                make.width.equalTo(600.0)
                make.leading.greaterThanOrEqualToSuperview()
            } else {
                make.leading.equalToSuperview()
            }
        }
        
        self.gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(2)
            make.top.equalTo(self.videoView.snp.centerY)
        }
    }
    
    private lazy var videoView: UIView = {
        VideosPlayView()
    }()
    
    private lazy var gradientView: UIView = {
        let gradientView = UIView()
        if IsIPad {
            gradientView.gl_setGradientColors([.gl_color(0x15141B, alpha: 0.0), .gl_color(0x15141B)], vertical: true)
        } else {
            gradientView.gl_setGradientColors([.gl_color(0x000000, alpha: 0.0), .gl_color(0x000000)], vertical: true)
        }
        return gradientView
    }()
}
