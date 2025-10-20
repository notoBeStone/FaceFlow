//
//  RestoreOtherUserAlertViewController.swift
//  AINote
//
//  Created by Martin on 2022/10/20.
//

import GLAnalyticsUI
import GLResource
import GLUtils
import UIKit
import SnapKit
import GLWidget

class RestoreOtherUserAlertViewController: GLBaseViewController, GLAPageProtocol {
    var pageName: String? = "restoreotheruseralert"
    
    var handler: ((_ confirm: Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHiddenNavigationBar = false
    }
    
    override func setNavigationView() {
        super.setNavigationView()
        self.navigationView.addLeftItem(self.backButton)
    }
    
    override func setUI() {
        super.setUI()
        self.view.addSubview(contentView)
        contentView.gl_addSubviews([titleLabel, descLabel, confirmBtn])
    }
    
    override func setConstraint() {
        super.setConstraint()
        let leading = 16.0
        let topEdge = IsIPad ? 50.0 : 15.0
        contentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            if IsIPad {
                make.width.equalToSuperview().multipliedBy(0.8)
            } else {
                make.leading.equalTo(leading)
            }
            make.top.equalTo(navigationView.snp.bottom).offset(topEdge)
            make.bottom.equalToSuperview().inset(topEdge)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20.0)
            make.leading.equalTo(leading)
            make.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
        }
        
        let height = 46.0
        confirmBtn.snp.makeConstraints { make in
            make.leading.equalTo(leading)
            make.top.equalTo(descLabel.snp.bottom).offset(80.0)
            make.centerX.equalToSuperview()
            make.height.equalTo(height)
        }
        confirmBtn.layer.cornerRadius = height / 2
    }
    
    // MARK: - Actions
   override func backButtonClick() {
        self.gl_track(type: .click, name: "back")
        self.dismiss(animated: true)
        self.handler?(false)
    }
    
    @objc private func confirmAction() {
        self.gl_track(type: .click, name: "confirm")
        self.dismiss(animated: true)
        self.handler?(true)
    }
    
    // MARK: - Lazy load
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = UIColor.gW
        contentView.layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 8.0
        contentView.gl_addOuterShadow(
            offset: CGSize(width: 0, height: 4),
            radius: 13.0,
            color: UIColor.gl_color(0x293033, alpha: 0.08)
        )
        return contentView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(
            title: GLModulesLanguage.text_restore_membership,
            color: UIColor.g9,
            font: UIFont.headlineMedium,
            alignment: .center
        )
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel(
            color: UIColor.g5,
            font: .footnoteRegular,
            alignment: .center
        )
        label.gl_setText(GLModulesLanguage.text_restore_membership_desc, lineHeight: 24.0)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var confirmBtn: UIButton = {
        let button = UIButton(
            title: GLModulesLanguage.text_continue,
            color: .white,
            font: .bodyMedium,
            backgroundColor: UIColor.p5
        )
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return button
    }()
}
