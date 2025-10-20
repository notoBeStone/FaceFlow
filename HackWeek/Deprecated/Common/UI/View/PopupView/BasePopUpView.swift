//
//  PopUpView.swift
//  DangJi
//
//  Created by Martin on 2021/11/15.
//  Copyright © 2021 Glority. All rights reserved.
//

import UIKit
import GLUtils
import SnapKit
import GLAnalyticsUI
import Combine
import GLResource

@objc
open class BasePopUpView: UIView, CombineActionProtocol {
    var cancellables = Set<AnyCancellable>()
    private var duration: Double {
        return 0.3
    }
    
    var mkAlpha: Double {
        return 0.7
    }
    
    private var shown: Bool = false
    private var keyboardShow: Bool = false
    public var blankClickHandler: ((BasePopUpView)->())?
    
    init() {
        super.init(frame: ScreenBounds)
        configUI()
    }
    
    override public init(frame: CGRect = ScreenBounds) {
        super.init(frame: frame)
        configUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        gl_addSubviews([mkView, tapButton, contentView])
        mkView.frame = bounds
        tapButton.frame = bounds
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        self.keyboardHelper.config()
    }
    
    @objc
    public func show(in view: UIView? = nil, _ shown: Bool, animated: Bool, completion:@escaping ()->()) {
        if shown {
            show(in: view, animated: animated, completion: completion)
        } else {
            dismiss(animated: animated, completion: completion)
        }
        self.shown = shown
        self.keyboardHelper.enable = shown && self.shouldResponseToKeyboard
        
        if shown {
            self.gl_track(type: .exposure, name: nil)
        }
    }
    
    private func show(in view: UIView? = nil, animated: Bool, completion:@escaping ()->()) {
        if superview == nil {
            var supView: UIView? = KeyWindow()
            if let view = view {
                supView = view
            }
            
            guard let supView = supView else {
                completion()
                return
            }
            
            supView.addSubview(self)
            self.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            contentView.snp.makeConstraints { make in
                self.keyboardHelper.keyboardContentBottomConstraint = make.top.equalTo(snp.bottom).constraint
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        self.keyboardHelper.keyboardContentBottomConstraint?.deactivate()
        contentView.snp.makeConstraints { make in
            self.keyboardHelper.keyboardContentBottomConstraint = make.bottom.equalToSuperview().constraint
        }
        
        if animated {
            setNeedsLayout()
            setTapEnable(false)
            UIView.animate(withDuration: self.duration) {
                self.mkView.alpha = self.mkAlpha
                self.layoutIfNeeded()
            } completion: { _ in
                self.setTapEnable(true)
                self.mkView.alpha = self.mkAlpha
                completion()
            }
            
        } else {
            setTapEnable(true)
            self.contentView.isUserInteractionEnabled = true
            self.mkView.alpha = self.mkAlpha
            completion()
        }
    }
    
    private func setTapEnable(_ enable: Bool) {
        self.contentView.isUserInteractionEnabled = enable
        self.tapButton.isUserInteractionEnabled = enable
    }
    
    @objc
    public func dismiss(animated: Bool, completion:@escaping ()->()) {
        if superview == nil {
            completion()
            return
        }
        
        if !animated {
            removeFromSuperview()
            completion()
            return
        }
        
        if animated {
            self.keyboardHelper.keyboardContentBottomConstraint?.deactivate()
            contentView.snp.makeConstraints { make in
                self.keyboardHelper.keyboardContentBottomConstraint = make.top.equalTo(snp.bottom).constraint
            }
            setNeedsLayout()
            isUserInteractionEnabled = false
            UIView.animate(withDuration: self.duration) {
                self.mkView.alpha = 0.0
                self.layoutIfNeeded()
            } completion: { _ in
                self.removeFromSuperview()
                completion()
            }
        }
    }
    
    var contentCormnerRadius: CGFloat {
        return 16.rpx
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.gl_roundCorners(.top, radius: contentCormnerRadius)
        mkView.frame = bounds
        tapButton.frame = bounds
    }
    
    func appendTextEditor(_ view: UIView, inset: Double = 10.0, fullRaised: Bool = false) {
        self.keyboardHelper.appendTextEditor(view, inset: inset, fullRaised: fullRaised)
    }
    
    var shouldResponseToKeyboard: Bool {
        return false
    }
    
    var introspectTextEditorAction: PassthroughSubject<KeybaordAvoidCoveredTextEditor, Never>? {
        return nil
    }
    
    //MARK: lazy load
    private(set) lazy var mkView: UIView = {
        let mkView = UIView()
        mkView.backgroundColor = .black
        mkView.alpha = 0.0
        return mkView
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .g0
        return view
    }()
    
    private lazy var tapButton: UIButton = {
        let button = UIButton()
        button.rac_signal(for: .touchUpInside).subscribeNext { _ in
            self.blankClickHandler?(self)
        }
        return button
    }()
    
    private lazy var keyboardHelper: KeybaordAvoidCoveredHelper = {
        let helper = KeybaordAvoidCoveredHelper(owner: self)
        return helper
    }()
}

extension BasePopUpView: KeybaordAvoidCoveredProtocol {
    var ownerView: UIView {
        return self
    }
    
    var keyboardContentView: UIView {
        return self.contentView
    }
}
