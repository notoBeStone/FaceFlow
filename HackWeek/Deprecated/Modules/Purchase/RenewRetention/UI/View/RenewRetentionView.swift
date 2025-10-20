//
//  RenewRetentionView.swift
//  DangJi
//
//  Created by yao.chengzhen on 2023/5/16.
//  Copyright © 2023 Glority. All rights reserved.
//

import UIKit
import GLUtils
import SnapKit

class RenewRetentionView: UIView {
    var termUseClonse: (() -> Void)?
    var privacyClonse: (() -> Void)?
    var subClonse: (() -> Void)?
    private var giveUpClonse: (() -> Void)
    private var continueClonse: (() -> Void)
    private let addEquityType: RenewRetentionManager.RenewType
    private var hasTouchedView = false

    init(addEquityType: RenewRetentionManager.RenewType, giveUpClonse: @escaping (() -> Void), continiueClonse: @escaping (() -> Void)) {
        self.giveUpClonse = giveUpClonse
        self.continueClonse = continiueClonse
        self.addEquityType = addEquityType
        super.init(frame: .zero)
        configUI()

        // 5s 执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
            self.scrollView.contentSize = CGSize.init(width: self.gl_width, height: self.contentView.gl_height)
            if self.hasTouchedView == false {
                self.scrollView.scrollRectToVisible(CGRect.init(origin: CGPoint.init(x: 0, y: self.contentView.gl_height - 1), size: CGSize.init(width: 10, height: 1)), animated: true)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 监听是不是，scrollView
        hasTouchedView = true
    }

    //MARK: configUI
    private func configUI() {
        let rate = ScreenHeight / GLFrameSize3(1024, 812, 667, 568)
        addSubview(scrollView)
        addSubview(bottomGuideView)

        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bottomGuideView.snp.top)
        }
        
        bottomGuideView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(IsIPhoneX ? 20 : IsIPad ? 24 : 12)
        }
        
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(ScreenWidth)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
        
        contentView.gl_addSubviews([topView, thirtyView, askExpertyView, booksView])
        bottomGuideView.gl_addSubviews([bottomView, bottomDescLabel])
        let width = GLFrameSize3(460, 336, 336, 286) * rate
        topView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(GLFrameSize3(80, 80, 70, 50) * rate)
            make.width.equalTo(width)
        }
        thirtyView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.top.equalTo(topView.snp.bottom).offset(GLFrameSize3(40, 20, 10, 8) * rate)
            make.centerX.equalToSuperview()
        }
        
        askExpertyView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.top.equalTo(thirtyView.snp.bottom).offset(GLFrameSize3(28, 15, 4, 4) * rate)
            make.centerX.equalToSuperview()
        }
        
        booksView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.centerX.equalToSuperview()
            make.top.equalTo(askExpertyView.snp.bottom).offset(GLFrameSize3(28, 15, 4, 4) * rate)
            make.bottom.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
        
        bottomDescLabel.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.top.equalTo(bottomView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    //MARK: - lazy
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never

        return scrollView
    }()
    
    private lazy var bottomGuideView: UIView = {
        let view = UIView()
        view.backgroundColor = .gl_color(0x000000)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    private lazy var topView: AddEquityTopView = {
        let topView = AddEquityTopView.init(addEquityType: addEquityType)
        return topView
    }()
    
    private lazy var bottomView: AddEquityBottomView = {      
        let bottomView = AddEquityBottomView(type: addEquityType) {[weak self] in
            self?.continueClonse()
        }
        bottomView.termUseClonse = {[weak self] in
            self?.termUseClonse?()
        }
        bottomView.privacyClonse = {[weak self] in
            self?.privacyClonse?()
        }
        bottomView.subClonse = {[weak self] in
            self?.subClonse?()
        }
        return bottomView
    }()
    
    private lazy var thirtyView: AddEquityItemCell = {
        let view = AddEquityItemCell.init(model: RenewRetentionManager.moreDayEquityModel, type: addEquityType)
        return view
    }()
    
    private lazy var askExpertyView: AddEquityItemCell = {
        let view = AddEquityItemCell.init(model: RenewRetentionManager.askExpertModel, type: addEquityType)
        return view
    }()
    
    private lazy var booksView: AddEquityItemCell = {
        let view = AddEquityItemCell.init(model: RenewRetentionManager.bookModel, type: addEquityType)
        return view
    }()
    
    private lazy var bottomDescLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.regular(IsIPad ? 14 : 12)
        view.numberOfLines = 0;
        view.textColor = UIColor.gl_color(0x999999)
        
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.12
        style.lineBreakMode = .byTruncatingTail
        view.attributedText = NSAttributedString(string: GLMPLanguage.homepop_note_b, attributes: [.paragraphStyle: style])
        return view
    }()
}




//MARK: - TopView
class AddEquityTopView: UIView {
    //Type
    private let addEquityType: RenewRetentionManager.RenewType
    
    //阴影偏移量
    private var shadowOffset: CGFloat {
        return addEquityType.topShadowffset
    }
    
    init(addEquityType: RenewRetentionManager.RenewType) {
        self.addEquityType = addEquityType
        super.init(frame: .zero)
        createAttr()
        configUI()

        self.layoutIfNeeded()
        self.topBgView.gl_addInnerShadow(insets: UIEdgeInsets(top: self.shadowOffset, left: self.shadowOffset, bottom: self.shadowOffset, right: self.shadowOffset), radius: 2, color: UIColor.gl_color(0x543C00, alpha: 0.4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - attr
    private func createAttr() {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.15
        style.alignment = .center
        style.lineBreakMode = .byTruncatingTail
        let valueTitle = String(format: addEquityType.topTitle, RenewRetentionManager.userVipTimeText.expertAt)
        
        //富文本加图片
        let attr = NSMutableAttributedString(string: " " + valueTitle + " ", attributes: [.paragraphStyle: style])
        
        let attrImage = NSAttributedString(attachment: createAttachment())
        attr.insert(attrImage, at: 0)
        
        //尾部添加图片
        let attrImage2 = NSAttributedString(attachment: createAttachment())
        attr.append(attrImage2)
        topLabel.attributedText = attr
    }
    
    private func createAttachment() -> NSTextAttachment {
        let image = UIImage(named: "equity_tip_icon")
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: IsIPhone5 ? 0 : 2, y: IsIPad ? 4 : 2, width: 11.5, height: 8.5)
        return attachment
    }
    
    //MARK: - configUI
    private func configUI() {
        let rate = ScreenHeight / GLFrameSize3(1024, 812, 667, 480)
        gl_addSubviews([bgView, topBgView, topImageView, topLabel])
        bgView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(22)
            make.bottom.equalToSuperview()
        }
        
        topBgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        topImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(topImageView.snp.width).multipliedBy(0.33)
        }
        
        topLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(26 * rate)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(topImageView.snp.top).offset(20)
            make.top.equalToSuperview().offset(GLFrameSize2(18, 18, 14) * rate)
        }
    }
    
    //MARK: - lazy
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium((IsIPad ? 18 : 16))
        label.textColor = .gl_color(0x705306)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var topImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "equity_top_bg_icon")
        return view
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gl_color(0x9F7B45)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var topBgView: UIView = {
        let view = UIView()
        view.backgroundColor = addEquityType.topContentBgColor
        view.layer.cornerRadius = 16
        return view
    }()
}
fileprivate extension RenewRetentionManager.RenewType {
    
    /// 顶部标题
    var topTitle: String {
        return GLMPLanguage.seasonpop_nowelcome
    }
    
    /// 顶部背景色
    var topContentBgColor: UIColor {
        return UIColor.gl_color(0xFCFAF3)
    }
    
    //topShawoffset
    var topShadowffset: CGFloat {
        return 10
    }
    
}

//MARK:  - BottomView

class AddEquityBottomView: UIView {
    var termUseClonse: (() -> Void)?
    var privacyClonse: (() -> Void)?
    var subClonse: (() -> Void)?
    
    private var continueClonse: (() -> Void)
    private var btnTitle: String?
    private let addEquityType: RenewRetentionManager.RenewType


    init(type: RenewRetentionManager.RenewType, continiueClonse: @escaping (() -> Void)) {
        self.continueClonse = continiueClonse
        self.btnTitle = type.submitTitle
        self.addEquityType = type
        
        super.init(frame: .zero)
        configUI()
        // 更新价格
        updatePrice()
        updateFont()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - action
    @objc
    private func continueBtnClick() {
        self.continueClonse()
    }
    
    //MARK: - configUI
    private func configUI() {
        addSubview(continiuBtn)
        addSubview(gradientView)
        addSubview(actionBottomView)
        
        //布局
        gradientView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }

        continiuBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(gradientView.snp.centerY)
            make.height.equalTo(IsIPhone5 ? 46 : 56)
        }
        
        actionBottomView.isHidden = false
        actionBottomView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(continiuBtn.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.gradientView.gl_roundCorners([.right, .topLeft], radius: 12)
        }

    }
    // MARK: - list
    private var itemList: [UILabel] = []
    // MARK: - 更新Font
    private func updateFont() {
        let rate = ScreenHeight / GLFrameSize3(1024, 812, 667, 568)

        let maxWidth = GLFrameSize3(460, 336, 336, 286) * rate
        var caculateWidth: CGFloat = 0
        var fontsize: CGFloat = 11
        let space: CGFloat = 4
        for label in itemList {
            caculateWidth += (label.text ?? "").sizeWidth(font: UIFont.regular(11))
        }
        var limitTimes = 0
        while (caculateWidth > maxWidth - space * 4) {
            fontsize = fontsize - 1
            caculateWidth = 0
            limitTimes += 1
            if limitTimes > 60 {
                break;
            }
            for label in itemList {
                caculateWidth += (label.text ?? "").sizeWidth(font: UIFont.regular(fontsize))
            }
        }
        for label in itemList {
            label.font = UIFont.regular(fontsize)
        }
    }
    
    //MARK: - lazy
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.gl_setGradientColors([UIColor.gl_color(0xBFFF38),
                                   UIColor.gl_color(0x2CF6BF)])
        view.gl_gradientAddToBottomLevel = true
        view.addSubview(noAdditionalLabel)
        noAdditionalLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }
        return view
    }()

    private lazy var continiuBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(btnTitle, for: .normal)
        btn.setTitleColor(.gl_color(0x000000), for: .normal)
        btn.titleLabel?.font = UIFont.heavy(18)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.backgroundColor = .gl_color(0xFFFFFF)
        btn.layer.cornerRadius = IsIPhone5 ? 23 : 28
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(continueBtnClick), for: .touchUpInside)
        return btn
    }()

    private lazy var noAdditionalLabel: UILabel = {
        let label = UILabel()
        label.text = GLMPLanguage.seasonpop_nopayment
        label.textColor = .gl_color(0x979797)
        label.font = UIFont.medium(IsIPad ? 16 : 14)
        return label
    }()
    
    // actionBottomView
    private lazy var actionBottomView: UIView = {
        let view = UIView()
        view.addSubview(startFromLabel)
        view.addSubview(stackView)
        startFromLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(startFromLabel.snp.bottom).offset(GLFrameSize3(30, 24, 16, 12))
            make.leading.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    // start from
    private lazy var startFromLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gl_color(0xffffff)
        label.font = UIFont.regular(IsIPad ? 16 : 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stackView: UIView = {
        let view = UIView()

        let line1 = createLine()
        let line2 = createLine()
        view.gl_addSubviews([termsOfUserLabel, privacyPolicyLabel, line1, line2, subLabel])
        
        itemList.append(termsOfUserLabel)
        itemList.append(privacyPolicyLabel)
        itemList.append(subLabel)
        
        termsOfUserLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        line1.snp.makeConstraints { make in
            make.leading.equalTo(termsOfUserLabel.snp.trailing).offset(4)
            make.centerY.equalTo(termsOfUserLabel)
            make.width.equalTo(1)
            make.height.equalTo(9)
        }
        privacyPolicyLabel.snp.makeConstraints { make in
            make.leading.equalTo(line1.snp.trailing).offset(4)
            make.centerY.equalTo(termsOfUserLabel)
            make.top.equalToSuperview()
        }
        
        line2.snp.makeConstraints { make in
            make.leading.equalTo(privacyPolicyLabel.snp.trailing).offset(4)
            make.centerY.equalTo(privacyPolicyLabel)
            make.width.equalTo(1)
            make.height.equalTo(9)
        }
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(line2.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.centerY.equalTo(privacyPolicyLabel)
        }
        return view
    }()
    
    private func createLine()-> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.gl_color(0xffffff, alpha: 1)
        return view
    
    }

    private lazy var termsOfUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gl_color(0xffffff)
        label.font = UIFont.regular(11)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = GLMPLanguage.protocol_termsofuse
        label.isUserInteractionEnabled = true
        label.gl_performAction(onTap: { [weak self] _ in
            self?.termUseClonse?()
        }, backgroundOnly: false)
        return label
    }()
    
    private lazy var privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gl_color(0xffffff)
        label.font = UIFont.regular(11)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.text = GLMPLanguage.protocol_privacypolicy
        label.gl_performAction(onTap: { [weak self] _ in
            self?.privacyClonse?()
        }, backgroundOnly: false)
        return label
    }()
    
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gl_color(0xffffff)
        label.font = UIFont.regular(11)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = true
        label.gl_performAction(onTap: { [weak self] _ in
            self?.subClonse?()
        }, backgroundOnly: false)
        label.text = GLMPLanguage.ptioszy4_firstconversionpage_subscriptionterms
        return label
    }()
    
    // 更新价格信息
    func updatePrice() {
        self.configFromlabel(expertAt: RenewRetentionManager.userVipTimeText.expertAt, price: "?")
        RenewRetentionManager.getVipInfo {[weak self] expertAt, price in
            self?.configFromlabel(expertAt: expertAt, price: price)
        }
    }
    private func configFromlabel(expertAt: String, price: String) {
        //seasonpop_welcomestart
        let title = String(format: GLMPLanguage.seasonpop_welcomestart, expertAt, price)
        let attr = NSMutableAttributedString(string: title)
        let range = (title as NSString).range(of: price)
        if range.location != NSNotFound {
            attr.addAttributes([.font: UIFont.semibold(IsIPad ? 16 : 14)], range: range)
        }
        startFromLabel.attributedText = attr
    }
    
}
fileprivate extension RenewRetentionManager.RenewType {
    
    /// 提交按钮标题
    var submitTitle: String? {
        return GLMPLanguage.homepop_button1_b
    }
    
}

fileprivate extension String {
    func sizeWidth(font: UIFont) -> CGFloat {
        if self.count == 0 {
            return 0
        }
        let attr = NSAttributedString(string: self, attributes: [.font: font])
        let size = attr.boundingRect(with: CGSize.init(width: Double(MAXFLOAT), height: 20.0), options: .usesLineFragmentOrigin, context: nil).size
        return size.width
    }
}


//MARK: - Cell

class AddEquityItemCell: UIView {
    let model: RenewRetentionManager.EquityItemModel
    let type: RenewRetentionManager.RenewType
    
    //init
    init(model: RenewRetentionManager.EquityItemModel, type: RenewRetentionManager.RenewType) {
        self.model = model
        self.type = type
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - configui
    func configUI() {
        //添加子视图
        addSubview(leftIcon)
        addSubview(topTitleLabel)
        addSubview(descLabel)
        addSubview(rightIcon)

        //布局
        leftIcon.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(-7)
            make.width.height.equalTo(60)
            make.bottom.lessThanOrEqualToSuperview().offset(0)
        }
        rightIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(10)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        
        self.layoutIfNeeded()
        
        topTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(leftIcon.snp.trailing).offset(5)
            make.trailing.equalTo(rightIcon.snp.leading).offset(-6)
            make.top.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(topTitleLabel)
            make.trailing.equalTo(topTitleLabel)
            make.top.equalTo(topTitleLabel.snp.bottom).offset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(0)
        }
    }
    //MARK: - lazy
    private lazy var leftIcon: UIImageView = {
        let leftIcon = UIImageView()
        leftIcon.contentMode = .scaleAspectFit
        leftIcon.image = UIImage(named: model.icon)
        return leftIcon
    }()
    
    private lazy var topTitleLabel: UILabel = {
        let topTitleLabel = UILabel()
        topTitleLabel.font = UIFont.regular(IsIPad ? 18 : 16)
        topTitleLabel.textColor = .gl_color(0xFFFFFF)
        topTitleLabel.textAlignment = .center
        topTitleLabel.numberOfLines = 0
        topTitleLabel.attributedText = model.title

        return topTitleLabel
    }()
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.font = UIFont.regular(IsIPad ? 14 : 12)
        descLabel.textColor = .gl_color(0x999999)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.attributedText = model.desc
        return descLabel
    }()
    
    private lazy var rightIcon: UIImageView = {
        let rightIcon = UIImageView()
        rightIcon.contentMode = .scaleAspectFit
        rightIcon.image = UIImage(named: "addequity_select_icon")
        return rightIcon
    }()
}
