//
//  ManageSubDefaultVipInfoView.swift
//  GLMSubDefault
//
//  Created by user on 2023/10/20.
//

import Foundation
import GLUtils
import GLCore
import GLResource
import GLComponentAPI
import SnapKit
import GLPurchaseExtension

@objc
class ManageSubDefaultVipInfoView : GLBaseView {
    
    override func createSubView() {
        super.createSubView()
        
        addViews()
        addConstraints()
        congifViews()
    }
    
    //MARK: - Public
    public func config(withVipInfo vipInfo: GLAPIVipInfo?) {
        guard let vipInfo = vipInfo else { return }
        
        var isTrial: Bool = false
        if let isTrialNum = vipInfo.isTrial, isTrialNum.boolValue == true {
            isTrial = true
        }
        
        // member since
        var date1 = NSDate()
        if let startAtNum = vipInfo.startAt, startAtNum.doubleValue > 0 {
            date1 = NSDate(timeIntervalSince1970: startAtNum.doubleValue)
        }
        let highlight1 = date1.gl_string(withFormat: "MMMM dd, yyyy")
        let title1 = MANAGESUBDEFAULT_SINCE.localizedOrMain(for: self.classForCoder, highlight1)
        let highlightColor1 = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack1, for: self.classForCoder)
        setAttTitle(memberSinceLabel, title: title1, highlight: highlight1, highlightColor: highlightColor1)
        
        // membership
        var highlight2 = MANAGESUBDEFAULT_PREMIUM.localizedOrMain(for: self.classForCoder)
        if isTrial {
            let trialDays = getTrialDays(vipInfo)
            highlight2 = MANAGESUBDEFAULT_PREMIUM_TRIAL.localizedOrMain(for: self.classForCoder, NSNumber(value: trialDays))
        }
        let title2 = MANAGESUBDEFAULT_MEMBERSGIP.localizedOrMain(for: self.classForCoder, highlight2)
        let highlightColor2 = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextPremium, for: self.classForCoder)
        setAttTitle(memberShipLabel, title: title2, highlight: highlight2, highlightColor: highlightColor2)
        
        //  bill end
        var highlight3 = ""
        var title3 = ""
        
        var date3 = NSDate()
        if let expiredAtNum = vipInfo.expiredAt, expiredAtNum.doubleValue > 0 {
            date3 = NSDate(timeIntervalSince1970: expiredAtNum.doubleValue)
        }
        if isTrial {
            let trialDays = date3.gl_days(from: Date())
            highlight3 = trialDays > 1
            ? MANAGESUBDEFAULT_DAYS.localizedOrMain(for: self.classForCoder, NSNumber(value: trialDays))
            : MANAGESUBDEFAULT_DAY.localizedOrMain(for: self.classForCoder, NSNumber(value: trialDays))
            title3 = MANAGESUBDEFAULT_TRIALEND.localizedOrMain(for: self.classForCoder, highlight3)
            
        } else {
            highlight3 = date3.gl_string(withFormat: "MMMM dd, yyyy")
            title3 = MANAGESUBDEFAULT_NEXT_BILLING.localizedOrMain(for: self.classForCoder, highlight3)
        }
        let highlightColor3 = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack1, for: self.classForCoder)
        setAttTitle(memberEndLabel, title: title3, highlight: highlight3, highlightColor: highlightColor3)

        //  bill period
        if let highlight4 = getBillPeriod(vipInfo) {
            var title4 =  MANAGESUBDEFAULT_BILL_PERIOD.localizedOrMain(for: self.classForCoder, highlight4)
            let highlightColor4 = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack1, for: self.classForCoder)
            setAttTitle(billPeriodLabel, title: title4, highlight: highlight4, highlightColor: highlightColor4)
            billPeriodLabel.isHidden = false
            
        } else {
            billPeriodLabel.isHidden = true
        }
    }
    
    //MARK: - Private
    private func getTrialDays(_ vipInfo: GLAPIVipInfo) -> Int {
        guard let sku = vipInfo.sku, sku.count > 0 else { return 7 }
        
        if let skuModel = GL().Purchase_GetSkuModel(forSku: vipInfo.sku) as? SkuSubscriptionModel {
            return skuModel.trailDays
        }
        return 7
    }
    
    private func getBillPeriod(_ vipInfo: GLAPIVipInfo) -> String? {
        guard let sku = vipInfo.sku, sku.count > 0 else { return nil }

        guard let skuModel = GL().Purchase_GetSkuModel(forSku: vipInfo.sku) as? SkuSubscriptionModel else {
            return nil
        }
        
        //  标记不显示 Period
        if let extra = skuModel.extra, let isShowPeriod = extra["isShowPeriod"] as? Bool, isShowPeriod == false {
            return nil
        }
        
        let type = skuModel.period
        if type == .yearly {
            return MANAGESUBDEFAULT_1_YEAR.localizedOrMain(for: self.classForCoder)
        } else if type == .seasonly {
            return MANAGESUBDEFAULT_3_MONTH.localizedOrMain(for: self.classForCoder)
        } else if type == .monthly {
            return MANAGESUBDEFAULT_1_MONTH.localizedOrMain(for: self.classForCoder)
        } else if type == .weekly {
            return MANAGESUBDEFAULT_1_WEEK.localizedOrMain(for: self.classForCoder)
        } else {
            //  unknow
        }
        
        return nil
    }
    
    private func setAttTitle(_ lable: UILabel, title: String, highlight: String, highlightColor: UIColor) {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lable.gl_lineHeight
        style.maximumLineHeight = lable.gl_lineHeight
        
        let attStr = NSMutableAttributedString(string: title,
                                               attributes: [.font: lable.font,
                                                            .paragraphStyle: style,
                                                            .foregroundColor: lable.textColor])
        if title.contains(highlight) {
            let range = (title as NSString).range(of: highlight)
            attStr.addAttributes([.font: UIFont.semibold(16.0.rpt), .foregroundColor: highlightColor], range: range)
        }
        lable.attributedText = attStr
    }
    
    //MARK: - UI
    private func congifViews() {
        backgroundColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicBackgroundVip, for: self.classForCoder)
        layer.cornerRadius = 10.rpt
        
        gl_addOuterShadow(offset: CGSize(width: 0, height: 4), radius: 10, color: UIColor.colorOrMain(ManageSubDefaultColor.dynamicShadowVip, for: self.classForCoder))
    }
    
    private func addViews() {
        addSubview(memberSinceLabel)
        addSubview(memberShipLabel)
        addSubview(memberEndLabel)
        addSubview(billPeriodLabel)

    }
    
    private func addConstraints() {
        memberSinceLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16.0.rpt)
        }
        
        memberShipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16.0.rpt)
            make.top.equalTo(memberSinceLabel.snp.bottom).offset(12.0.rpt)
        }
        
        memberEndLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16.0.rpt)
            make.top.equalTo(memberShipLabel.snp.bottom).offset(12.0.rpt)
        }
        
        billPeriodLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16.0.rpt)
            make.top.equalTo(memberEndLabel.snp.bottom).offset(12.0.rpt)
        }
    }
    
    //MARK: - lazy
    private lazy var memberSinceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(16.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack3, for: self.classForCoder)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var memberShipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(16.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack3, for: self.classForCoder)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var memberEndLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(16.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack3, for: self.classForCoder)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var billPeriodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium(16.rpt)
        label.gl_lineHeight = 20.0.rpt
        label.textColor = UIColor.colorOrMain(ManageSubDefaultColor.dynamicTextBlack3, for: self.classForCoder)
        label.numberOfLines = 0
        return label
    }()
}

