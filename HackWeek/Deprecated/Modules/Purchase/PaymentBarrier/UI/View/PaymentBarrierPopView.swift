//
//  PaymentBarrierPopView.swift
//  AINote
//
//  Created by user on 2024/6/7.
//

import UIKit
import GLUtils
import GLAnalyticsUI
import GLMP

class PaymentBarrierPopView: UIView, GLAPageProtocol {
    
    var pageName: String? { "paymentbarrierpop" }
    
    var nextClosure: (() -> Void)?
    
    required init() {
        super.init(frame: .zero)
        addViews()
        addLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.gl_roundCorners(.top, radius: 20)
    }
    
    private lazy var blackView: UIView = {
        let view = UIView()
        view.alpha = 0.6
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .gl_colorDynamic(light: 0xFFFFFF, dark: 0x262626)
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "payment_barrier_tips")
        return imageView
    }()
    
    private lazy var titleLb: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gl_colorDynamic(light: 0x000000, dark: 0xFFFFFF)
        label.text = GLMPLanguage.billingissue1_text
        label.font = .bold(22)
        return label
    }()
    
    private lazy var contentLb: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gl_colorDynamic(light: 0x333333, dark: 0xCCCCCC)
        label.text = String.init(format: GLMPLanguage.billingissue2_text, String(PaymentBarrierManager.expireInDay))
        label.font = .medium(16)
        return label
    }()
    
    private lazy var updateBtn: UIButton = {
        let button = UIButton()
        button.setTitle(GLMPLanguage.billingissue3_text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .semibold(18)
        button.backgroundColor = .gl_color(0x1BB38D)
        button.addTarget(self, action: #selector(updateBtnClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var dismissBtn: UIButton = {
        let button = UIButton()
        button.setTitle(GLMPLanguage.billingissue4_text, for: .normal)
        button.setTitleColor(.gl_colorDynamic(light: 0x333333, dark: 0xFFFFFF), for: .normal)
        button.titleLabel?.font = .semibold(18)
        button.backgroundColor = .gl_colorDynamic(light: 0xF0F0F0, dark: 0x333333)
        button.addTarget(self, action: #selector(dismissBtnClicked), for: .touchUpInside)
        return button
    }()
}

extension PaymentBarrierPopView {
    
    @objc
    func dismissBtnClicked() {
        gl_track(type: .click, name: "dismiss")
        dismiss()
        nextClosure?()
    }
    
    @objc
    func updateBtnClicked() {
        gl_track(type: .click, name: "update")
        dismiss()
        nextClosure?()
        PaymentBarrierManager.updatePaymentMethod()
    }
}

extension PaymentBarrierPopView {
    
    func addViews() {
        addSubview(blackView)
        addSubview(contentView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLb)
        contentView.addSubview(contentLb)
        contentView.addSubview(updateBtn)
        contentView.addSubview(dismissBtn)
    }
    
    func addLayouts() {
        blackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(23)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        titleLb.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(iconView.snp.bottom).offset(12)
        }
        
        contentLb.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLb)
            make.top.equalTo(titleLb.snp.bottom).offset(10)
        }
        
        updateBtn.snp.makeConstraints { make in
            make.top.equalTo(contentLb.snp.bottom).offset(24)
            make.leading.trailing.equalTo(contentLb)
            make.height.equalTo(50)
        }
        updateBtn.layer.cornerRadius = 25
        
        dismissBtn.snp.makeConstraints { make in
            make.leading.trailing.equalTo(updateBtn)
            make.top.equalTo(updateBtn.snp.bottom).offset(12)
            make.height.equalTo(updateBtn)
            make.bottom.equalToSuperview().inset(IPhoneXBottomHeight + 16)
        }
        dismissBtn.layer.cornerRadius = 25
    }
}

//MARK: - Display & Dismiss
extension PaymentBarrierPopView {
    
    class func show(next: @escaping () -> Void) {
        
        guard let window = KeyWindow() else {
            return
        }
        
        let view = Self()
        view.nextClosure = next
        window.addSubview(view)
        view.frame = window.bounds
        view.blackView.alpha = 0
        view.contentView.snp.remakeConstraints { make in
            make.top.equalTo(view.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        view.contentView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            view.blackView.alpha = 0.6
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        
        GLMPTracking.tracking("paymentbarrierpop_exposure")
    }
    
    func dismiss() {
        contentView.snp.remakeConstraints { make in
            make.top.equalTo(self.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
