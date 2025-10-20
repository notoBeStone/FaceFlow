//
//  AppUpgradeAlertView.swift
//  AINote
//
//  Created by user on 2024/3/26.
//

import UIKit
import GLUtils
import GLResource

class AppUpgradeAlertView: BasePopCenterView {

    private let title: String
    private let desc: String
    var confirmHandler: (()->())?
    init(title: String, description: String, forced: Bool) {
        self.title = title
        self.desc = description
        super.init(frame: .zero)
        self.shouldShowCloseButton = !forced
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.contentView.gl_addSubviews([self.titleLabel, self.descLabel, self.updateButton])
        var topEdge = 36.0;
        var xEdge = 36.0;
        
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(xEdge)
            make.centerX.equalToSuperview()
            make.top.equalTo(topEdge)
        }
        
        topEdge = 6.0
        self.descLabel.snp.makeConstraints { make in
            make.leading.equalTo(xEdge)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(topEdge)
        }
        
        topEdge = 20.0;
        xEdge = 45.0;
        let bottomEdge = 36.0;
        self.updateButton.snp.makeConstraints { make in
            make.leading.equalTo(xEdge)
            make.top.equalTo(self.descLabel.snp.bottom).offset(topEdge)
            make.centerX.equalToSuperview()
            make.height.equalTo(38.0)
            make.bottom.equalToSuperview().inset(bottomEdge)
        }
    }
    
    //MARK: - Lazy load
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(color: UIColor.g9,
                                 font: .headlineMedium)
        titleLabel.textAlignment = .center
        titleLabel.gl_setText(self.title, lineHeight: 26.0)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel(color: UIColor.g9,
                            font: .headlineMedium)
        label.textAlignment = .center
        label.gl_setText(self.desc, lineHeight: 26.0)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var updateButton: UIButton = {
        var button = UIButton.init(type: .custom)
        button.layer.cornerRadius = 19
        button.backgroundColor = UIColor.p5
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .footnoteRegular
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitle(GLModulesLanguage.text_update, for: .normal)
        button.layer.shadowColor = UIColor.gl_color(0x3AC0B4, alpha: 0.3).cgColor
        button.layer.shadowOffset = .init(width: 0, height: 5)
        button.layer.shadowRadius = 13
        button.rac_signal(for: .touchUpInside).subscribeNext {[weak self] _ in
            self?.confirmHandler?()
        }
        return button
    }()

}


import GLUtils
import GLResource

class BasePopCenterView: UIView {
    
    var blankClikHandler: ((_ view: BasePopCenterView)->())? = nil
    
    var closeHandler: ((_ view: BasePopCenterView)->())? = nil
    
    var contentWidth: CGFloat {
        get {
            let leftEdge = 30.rpx
            var width = ScreenWidth - leftEdge * 2
            if IsIPad {
                width = 440.0
            }
            return width
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
            make.size.equalTo(CGSize.init(width: 44, height: 44))
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(30)
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
        view.layer.cornerRadius = 12
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
        btn.setImage(.init(named: "icon_alert_close"), for: .normal)
        btn.addTarget(self, action: #selector(clickedCloseButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tapButton: UIButton = {
        var btn = UIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return btn
    }()
}
