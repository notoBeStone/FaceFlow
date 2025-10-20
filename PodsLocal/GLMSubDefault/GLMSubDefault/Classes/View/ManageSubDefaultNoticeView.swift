//
//  ManageSubDefaultNoticeView.swift
//  GLMSubDefault
//
//  Created by user on 2023/10/23.
//

import Foundation
import GLUtils
import GLCore
import GLResource
import GLComponentAPI
import SnapKit
import GLPurchaseExtension

@objc
class ManageSubDefaultNoticeView : GLBaseView {
    
    override func createSubView() {
        super.createSubView()
        
        addViews()
        addConstraints()
        congifViews()
    }
    
    //MARK: - Public
    public func config(withVipInfo vipInfo: GLAPIVipInfo?) {
        guard let vipInfo = vipInfo else { return }
        
        //  trial
        if let isTrialNum = vipInfo.isTrial, isTrialNum.boolValue == true {
            itemLabel2.text = MANAGESUBDEFAULT_NOTICE_ITEM2_1.localizedOrMain(for: self.classForCoder)
        } else {
            itemLabel2.text = MANAGESUBDEFAULT_NOTICE_ITEM2_2.localizedOrMain(for: self.classForCoder)
        }
    }
    
    //MARK: - Private

    //MARK: - UI
    private func congifViews() {
        backgroundColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundWhite, for: self.classForCoder)
    }
    
    private func addViews() {
        addSubview(titleLabel)
        addSubview(countLabel1)
        addSubview(itemLabel1)
        addSubview(countLabel2)
        addSubview(itemLabel2)
        addSubview(countLabel3)
        addSubview(itemLabel3)
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24.0.rpt)
        }
        
        countLabel1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24.0.rpt)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        itemLabel1.snp.makeConstraints { make in
            make.leading.equalTo(countLabel1.snp.trailing)
            make.top.equalTo(countLabel1.snp.top)
            make.trailing.equalToSuperview().inset(24.0.rpt)
        }
        
        countLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24.0.rpt)
            make.top.equalTo(itemLabel1.snp.bottom)
        }
        
        itemLabel2.snp.makeConstraints { make in
            make.leading.equalTo(countLabel2.snp.trailing)
            make.top.equalTo(countLabel2.snp.top)
            make.trailing.equalToSuperview().inset(24.0.rpt)
        }
        
        countLabel3.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24.0.rpt)
            make.top.equalTo(itemLabel2.snp.bottom)
        }
        
        itemLabel3.snp.makeConstraints { make in
            make.leading.equalTo(countLabel3.snp.trailing)
            make.top.equalTo(countLabel3.snp.top)
            make.trailing.equalToSuperview().inset(24.0.rpt)
            make.bottom.equalToSuperview()
        }
    }
    
    //MARK: - lazy
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        let highlight = "* "
        let title = highlight + MANAGESUBDEFAULT_NOTICE.localizedOrMain(for: self.classForCoder) + ":"
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 20.0.rpt
        style.maximumLineHeight = 20.0.rpt
        let attStr = NSMutableAttributedString(string: title,
                                               attributes: [.font: UIFont.bold(13.rpt),
                                                            .paragraphStyle: style,
                                                            .foregroundColor: UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack1, for: self.classForCoder).withAlphaComponent(0.8)])
        if title.contains(highlight) {
            let range = (title as NSString).range(of: highlight)
            attStr.addAttributes([.foregroundColor: UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextNotice, for: self.classForCoder)],
                                 range: range)
        }
        label.attributedText = attStr
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var countLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(13.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder).withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.text = MANAGESUBDEFAULT_NOTICE_COUNT1.localizedOrMain(for: self.classForCoder)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var itemLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(13.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder).withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.text = MANAGESUBDEFAULT_NOTICE_ITEM1.localizedOrMain(for: self.classForCoder)
        return label
    }()
    
    private lazy var countLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(13.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder).withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.text = MANAGESUBDEFAULT_NOTICE_COUNT2.localizedOrMain(for: self.classForCoder)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var itemLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(13.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder).withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.text = MANAGESUBDEFAULT_NOTICE_ITEM2_1.localizedOrMain(for: self.classForCoder)
        return label
    }()
    
    private lazy var countLabel3: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(13.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder).withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.text = MANAGESUBDEFAULT_NOTICE_COUNT3.localizedOrMain(for: self.classForCoder)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var itemLabel3: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(13.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack2, for: self.classForCoder).withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.text = MANAGESUBDEFAULT_NOTICE_ITEM3.localizedOrMain(for: self.classForCoder)
        return label
    }()
}

