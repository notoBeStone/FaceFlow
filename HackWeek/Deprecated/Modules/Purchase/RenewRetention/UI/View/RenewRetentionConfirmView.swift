//
//  RenewRetentionConfirmView.swift
//  AINote
//
//  Created by user on 2024/5/30.
//

import UIKit
import GLUtils
import GLTextKit
import GLTrackingExtension
import GLMP

class RenewRetentionConfirmView: UIView {
    var closeClonse: (() -> Void)?
    var contactClonse: (() -> Void)?
    private let from: String
    // MARK: - Override
    init(frame: CGRect, from: String) {
        self.from = from
        super.init(frame: frame)
        configUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.bgView.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //
    @objc
    private func tapAction() {
        self.closeAction()
    }
    //MARK: - showAnimation
    func showAnimation() {
        self.bgView.alpha = 0
        self.contentView.gl_scale(0.01)
        UIView.animate(withDuration: 0.35) {
            self.bgView.alpha = 1
            self.contentView.gl_scale(1)
        } completion: { finish in
            
        }
        GLMPTracking.tracking("equityconfirmpage_confirm_exposure", parameters: [GLT_PARAM_FROM: from])
    }
    
    //MARK: - Action
    @objc
    private func closeAction(isConsult: Bool = false) {
        if isConsult {
            GLMPTracking.tracking("equityconfirmpage_contactus_click", parameters: [GLT_PARAM_FROM: from])
        } else {
            GLMPTracking.tracking("equityconfirmpage_close_click", parameters: [GLT_PARAM_FROM: from])
        }
        UIView.animate(withDuration: 0.35) {
            self.bgView.alpha = 0
            self.contentView.gl_scale(0.01)
        } completion: { finish in
            if isConsult {
                self.contactClonse?()
            } else {
                self.closeClonse?()
            }
            self.removeFromSuperview()
        }
    }
    //MARK: - configInfo
    private func configInfo(label: GLLinkLabel) {
        let title = String(format: RenewRetentionManager.confirmText)
        let sub = RenewRetentionManager.supportEmailText
        //富文本 行高 1.12
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.12
        style.alignment = .center
        style.lineBreakMode = .byTruncatingTail
        let attr = NSMutableAttributedString(string: title, attributes: [.paragraphStyle: style, .font: UIFont.regular(18)])
        //添加下划线
        let range = (title as NSString).range(of: sub)
        //添加判断，防止崩溃
        if range.location != NSNotFound {
            attr.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
            attr.addTap({[weak self] () in
                self?.closeAction(isConsult: true)
            }, range: range)
        }
        label.attributedText = attr
        self.titleLabel.attributedText = attr;
    }
    //MARK: - configUI
    private func configUI() {
        gl_addSubviews([bgView, contentView])
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(GLFrameSize2(400, 340, 280))
        }
        contentView.gl_addSubviews([closeBtn, linkLabel, titleLabel])
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(closeBtn.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(36)
            make.leading.equalToSuperview().offset(24)
        }
        linkLabel.snp.makeConstraints { make in
            make.edges.equalTo(titleLabel)
        }
    }
    //MARK: - lazy
    private lazy var bgView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.gl_color(0x000000, alpha: 0.5)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor.gl_colorDynamic(light: 0xffffff, dark: 0x1a1a1a)
        return view
    }()
    
    private lazy var closeBtn: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "icon_closedelePic"), for: .normal)
        view.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return view
    }()
    
    private lazy var linkLabel: GLLinkLabel = {
        let view = GLLinkLabel()
        configInfo(label: view)
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.isHidden = true
        return view
    }()
}
