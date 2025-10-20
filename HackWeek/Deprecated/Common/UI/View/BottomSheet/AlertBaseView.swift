//
//  BasePopUpView.swift
//  GLCMSResult
//
//  Created by user on 2024/5/13.
//

import UIKit
import SnapKit
import GLUtils

class AlertBaseView: UIView {
    public var blankClikHandler: ((AlertBaseView) -> Void)?
  
    private var topEdge: CGFloat {
        let topEdge: CGFloat = 40.0 + GLScreen.safeTop
        return topEdge
    }
    
    private var topConstraint: SnapKit.Constraint?
    private var bottomConstraint: SnapKit.Constraint?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupUI() {
        addSubview(mskView)
        addSubview(tapButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func setupConstraints() {
        mskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.greaterThanOrEqualTo(self.topEdge)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }
    }

    func updateScrollViewHeightWithContentSize(_ contentSize: CGSize) {
        self.scrollView.snp.makeConstraints { make in
            make.height.equalTo(contentSize.height).priority(.low)
        }
    }

    public func show(in view: UIView? = nil, animated: Bool, completion: (() -> Void)? = nil) {
        // Implementation for showing the popup view
        show(in: view, bottomEdge: 0.0, animated: true, completion: completion)
    }
    
    public func show(in view: UIView?, bottomEdge: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
        // Implementation for showing the popup view
        var parentView: UIView? = view
        if view == nil {
            parentView = UIApplication.shared.keyWindow
        }
        guard let parentView = parentView else {
            return
        }
        
        parentView.addSubview(self)
        self.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(bottomEdge)
        }
        
        if self.topConstraint == nil {
            scrollView.snp.makeConstraints { make in
                self.topConstraint = make.top.equalTo(self.snp.bottom).constraint
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
        
        if let topConstraint = topConstraint {
            topConstraint.deactivate()
            self.topConstraint = nil
        }
        
        let maskViewAlpha = 0.7
        
        if self.bottomConstraint == nil {
            self.mskView.alpha = maskViewAlpha
            scrollView.snp.makeConstraints { make in
                self.bottomConstraint = make.bottom.equalToSuperview().constraint
            }
        } else {
            bottomConstraint?.deactivate()
        }
        
        if animated {
            let animationDuration = 0.3
            setNeedsLayout()
            mskView.alpha = 0.0
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.layoutIfNeeded()
                self?.mskView.alpha = maskViewAlpha
            } completion: { finished in
                completion?()
            }
        } else {
            completion?()
        }
    }

    public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        // Implementation for dismissing the popup view
        bottomConstraint?.deactivate()
        
        if let topConstraint = self.topConstraint {
            topConstraint.deactivate()
        } else {
            scrollView.snp.makeConstraints { make in
                self.topConstraint = make.top.equalTo(self.snp.bottom).constraint
            }
        }
        
        if animated {
            let animationDuration = 0.3
            setNeedsLayout()
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.mskView.alpha = 0.0
                self?.layoutIfNeeded()
            } completion: { [weak self] finished in
                self?.removeFromSuperview()
                completion?()
            }
        } else {
            removeFromSuperview()
            completion?()
        }
    }

    public func keyboardWillShowHeight(_ height: CGFloat, duration: CGFloat) {
        // Implementation for handling keyboard show
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(height)
            }
        }
    }

    public func keyboardWillHide(duration: CGFloat) {
        // Implementation for handling keyboard hide
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(0)
            }
        }
    }
    
    
    
    //KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath ==  #keyPath(UIScrollView.contentSize), let newSize = change?[.newKey] as? CGSize  {
            updateScrollViewHeightWithContentSize(newSize)
        }
    }
    
    //Action
    
    @objc private func blankButtonTapped() {
        blankClikHandler?(self)
    }

    // Lazy loading of properties
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.new, .old], context: nil)
        return view
    }()
    
    internal lazy var contentView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 18.rpx
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var mskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var tapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(blankButtonTapped), for: .touchUpInside)
        return button
    }()

    
}

