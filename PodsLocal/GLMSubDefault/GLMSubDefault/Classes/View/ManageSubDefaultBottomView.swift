//
//  ManageSubDefaultBottomView.swift
//  GLMSubDefault
//
//  Created by user on 2023/10/20.
//

import Foundation
import GLUtils
import GLCore


@objc
class ManageSubDefaultBottomView : GLBaseView {
    
    public var keepBlock: (() -> Void)?
    public var cancelBlock: (() -> Void)?
    
    override func createSubView() {
        super.createSubView()
        
        addViews()
        addConstraints()
        congifViews()
    }
    
    //MARK: - Public
    
    //MARK: - Private
    @objc
    private func keepAction() {
        keepBlock?()
    }
    
    @objc
    private func cancelAction() {
        cancelBlock?()
    }
    
    //MARK: - UI
    private func congifViews() {
        backgroundColor = UIColor.clear
    }
    
    private func addViews() {
        addSubview(gradeientView)
        addSubview(backView)
        backView.addSubview(keepBtn)
        backView.addSubview(cancelBtn)
    }
    
    private func addConstraints() {
        gradeientView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(40.0.rpt)
        }
        
        backView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(gradeientView.snp.bottom)
        }
        
        keepBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24.0.rpt)
            make.top.equalToSuperview()
            make.height.equalTo(46.0.rpt)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24.0.rpt)
            make.top.equalTo(keepBtn.snp.bottom).offset(12.0.rpt)
            make.height.equalTo(46.0.rpt)
            make.bottom.equalToSuperview().offset(-20.0.rpt)
        }
    }
    
    
    //MARK: - lazy
    private lazy var gradeientView: UIView = {
        let view = UIView()
        view.gl_setGradientColors([UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder).withAlphaComponent(0),
                                   UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder)],
                                  vertical: true)
        view.gl_gradientAddToBottomLevel = true
        return view
    }()
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder)
        return view
    }()
    
    private lazy var keepBtn: UIButton = {
        let btn = UIButton()
        let cornerRadius = 23.0.rpt
        let title = MANAGESUBDEFAULT_KEEP_PLAN.localizedOrMain(for: self.classForCoder)
        let attString = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextWhite, for: self.classForCoder),
                                                                       .font: UIFont.semibold(18.0.rpt)])
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: cornerRadius, bottom: 0, trailing: cornerRadius)
            config.cornerStyle = .capsule
            config.attributedTitle = AttributedString(attString)
            btn.configuration = config
        } else {
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: cornerRadius, bottom: 0, right: cornerRadius)
            btn.setAttributedTitle(attString, for: .normal)
        }
        btn.layer.cornerRadius = cornerRadius
        btn.backgroundColor = UIColor.themeColor
        btn.addTarget(self, action: #selector(keepAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        let cornerRadius = 23.0.rpt
        let title = MANAGESUBDEFAULT_GO_CANCEL.localizedOrMain(for: self.classForCoder)
        let attString = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.themeColor,
                                                                       .font: UIFont.semibold(18.0.rpt)])
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: cornerRadius, bottom: 0, trailing: cornerRadius)
            config.cornerStyle = .capsule
            config.attributedTitle = AttributedString(attString)
            btn.configuration = config
        } else {
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: cornerRadius, bottom: 0, right: cornerRadius)
            btn.setAttributedTitle(attString, for: .normal)
        }
        btn.layer.cornerRadius = cornerRadius
        btn.backgroundColor = .clear
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.themeColor.cgColor
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
}
