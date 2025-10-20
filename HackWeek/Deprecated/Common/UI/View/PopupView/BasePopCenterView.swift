//
//  BasePopCenterView.swift
//  AINote
//
//  Created by 彭瑞淋 on 2022/9/29.
//

import UIKit
import GLUtils
import GLResource

class BasePopCenterView: UIView {
    
    var blankClikHandler: ((_ view: BasePopCenterView)->())? = nil
    
    var closeHandler: ((_ view: BasePopCenterView)->())? = nil
    
    var contentWidth: CGFloat {
        get {
            306.rpx
        }
    }
    
    var shouldShowCloseButton = true {
        didSet {
            self.closeButton.isHidden = !self.shouldShowCloseButton
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setUI() {
        addSubview(coverView)
        addSubview(tapButton)
        addSubview(contentView)
        addSubview(closeButton)
    }
    
    private func setConstraint() {
        coverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(self.contentWidth)
        }
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 44.rpx, height: 44.rpx))
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(16.rpx)
        }
    }
    
    // MARK: - Public Method
    
    public func showInView(_ view: UIView?, animated: Bool, completion: (()->())?) {
        if let superView = view {
            superView.addSubview(self)
        } else {
            KeyWindow()?.addSubview(self)
        }
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if animated {
            coverView.alpha = 0
            contentView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.coverView.alpha = self.maskAlpha
                self.contentView.alpha = 1.0
            } completion: { finish in
                completion?()
            }
        } else {
            coverView.alpha = self.maskAlpha
            completion?()
        }
    }
    
    public func dismissAnimated(_ flag: Bool, completion: (()->())?) {
        if flag {
            UIView.animate(withDuration: 0.3) {
                self.coverView.alpha = 0
                self.contentView.alpha = 0
            } completion: { finish in
                self.removeFromSuperview()
                completion?()
            }
        } else {
            self.removeFromSuperview()
            completion?()
        }
    }
    
    var maskAlpha: Double {
        return 0.7
    }
    
    // MARK: - Action
    @objc
    func clickedCloseButton() {
        self.closeHandler?(self)
    }
    
    @objc
    func tapAction() {
        self.blankClikHandler?(self)
    }
    
    // MARK: - Lazy Load
    
    public lazy var contentView: UIView = {
        var view = UIView.init()
        view.backgroundColor = .gW
        view.gl_cornerRadius = 12.rpx
        view.layer.shadowColor = UIColor.g9.cgColor
        view.layer.shadowOffset = .init(width: 0, height: 4)
        view.layer.shadowRadius = 13
        return view
    }()
    
    private lazy var coverView: UIView = {
        var view = UIView.init()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var btn = UIButton.init(type: .custom)
        btn.setImage(.init(named: "centeralert_close_btn"), for: .normal)
        btn.addTarget(self, action: #selector(clickedCloseButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tapButton: UIButton = {
        var btn = UIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return btn
    }()
}
