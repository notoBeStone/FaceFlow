//
//  Vip27584AContentView.swift
//  Vip27584
//
//  Created by Martin on 2024/3/27.
//

import UIKit
import GLUtils
import GLPurchaseUI
import GLResource
import GLCore
import GLPurchaseExtension

@objc public protocol Vip27616AContentViewDelegate: PurchaseTrailReminderDelegate {
    func closeAction()
    func startAction(_ type: Price27616Type)
    func termsOfUseAction()
    func privacyPolicyAction()
    func subscriptionAction()
    func restoreAction()
}

@objc
public class Vip27616AContentView: UIView {
    private weak var delegate: Vip27616AContentViewDelegate?
    private let languageType: GLLanguageEnum
    
    @objc
    public init(extra: [AnyHashable: Any]?, delegate: Vip27616AContentViewDelegate) {
        self.languageType = extra?.learnLanguageType ?? .English
        self.delegate = delegate
        super.init(frame: .zero)
        configUI()
        showPirce()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func showPirce() {
        self.showCurrentPriceType()
        self.priceView.showPrice()
    }
    
    private func configUI() {
        self.gl_addSubviews([headerImageView, gradientView, contentView, priceLabel, continueButton ,bottomActionView, cancelButton])
        self.contentView.gl_addSubviews([titleLabel, subLabel, featureView, priceView, reminderIconView, reminderView])
        titleLabel.numberOfLines = 0
        subLabel.numberOfLines = 0
        
        self.cancelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12.rpx)
            make.top.equalTo(StatusBarHeight)
        }
        self.headerImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(self.headerImageView.snp.width).multipliedBy(GLFrameSize1(552.0/834.0, 360.0/375.0))
        }
        
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.headerImageView)
            make.height.equalTo(self.headerImageView.snp.height).multipliedBy(0.5)
        }
        
        self.contentView.snp.makeConstraints { make in
//            make.top.equalTo(self.gradientView.snp.bottom).offset(-56.rpx)
            make.width.equalTo(self.contentWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.continueButton.snp.top).offset(-GLFrameSize1(100.0, 58.rpx))
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(0)
        }
        
        self.subLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom)
        }
        self.featureView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.subLabel.snp.bottom).offset(GLFrameSize1(24, 16))
        }
        
        self.priceView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.featureView.snp.bottom).offset(40.rpx)
        }
        
        self.reminderIconView.snp.makeConstraints { make in
            make.leading.equalTo(8.0)
            make.width.height.equalTo(24.0)
            make.centerY.equalTo(self.reminderView)
        }
        
        self.reminderView.snp.makeConstraints { make in
            make.leading.equalTo(self.reminderIconView.snp.trailing)
            make.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.priceView.snp.bottom).offset(GLFrameSize1(26, 16))
        }
        
        self.priceLabel.snp.makeConstraints { make in
            make.centerX.leading.equalToSuperview()
            make.bottom.equalTo(self.continueButton.snp.top).offset(-GLFrameSize4(16.0, 16.rpx, 16.rpx, 12.0))
        }
        
        let height = 56.rpx
        self.continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(self.contentView.snp.width)
            make.height.equalTo(height)
            make.bottom.equalTo(self.bottomActionView.snp.top).offset(-GLFrameSize1(56, 16.rpx))
        }
        self.continueButton.layer.cornerRadius = height / 2
        
        self.bottomActionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.continueButton.snp.bottom).offset(GLFrameSize1(36.0, 16.rpx))
            make.bottom.equalToSuperview().inset(GLFrameSize4(24.0, 20.0, 5.0, 5.0))
        }
    }
    
    @objc public func layout() {
        self.reminderView.layer.cornerRadius = self.reminderView.bounds.size.height / 2
    }
    
    func localized(key: String) -> String {
        key.localized(for: self.classForCoder, tableName: "Localizable27616")
    }
    
    @objc public var skuId: String {
        self.priceType.skuId
    }
    
    @objc public var trailable: Bool {
        return self.priceType.trailable
    }
    
    @objc public static var skuIds: [String] {
        Price27616Type.allCases.map {$0.skuId}
    }
    
    private func bottomActionTextType(_ type: BottomActionType) -> String {
        type.title
    }
    
    private var contentWidth: Double {
        if IsIPad {
            return min(500, ScreenWidth * 0.8)
        } else {
            return ScreenWidth - 24.rpx * 2
        }
    }
    
    private func showCurrentPriceType() {
        self.reminderView.isHidden = !self.priceType.trailable
        self.reminderIconView.isHidden = !self.priceType.trailable
        self.priceLabel.text = self.priceType.priceText
    }
    
    private var priceType: Price27616Type {
        self.priceView.selectedType
    }
    
    // MARK: - Lazy load
    @objc public lazy var cancelButton: UIButton = {
        let image = UIImage.imageOrMain("icon_cancel_27584", for: self.classForCoder) ?? UIImage()
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.gl_enlargeEdge(10)
        button.rac_signal(for: .touchUpInside).subscribeNext {[weak self] _ in
            self?.delegate?.closeAction()
        }
        return button
    }()
    
    private lazy var headerImageView: UIView = {
        let imageView = UIImageView()
        let iconName = IsIPad ? "header_pad_27584" : "header_phone_27584"
        imageView.image = UIImage.imageOrMain(iconName, for: self.classForCoder)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var gradientView: UIView = {
        let gradientView = UIView()
        gradientView.gl_setGradientColors([.gl_color(0x131023, alpha: 0.0), .gl_color(0x131023)], vertical: true)
        return gradientView
    }()
    
    
    
    private lazy var contentView = UIView()
    
    private lazy var titleLabel = UILabel(text: "conversionpage_title".vipLocalized(),
                                          color: .gW,
                                          font: .title2Bold,
                                          alignment: .center)
    
    private lazy var subLabel = UILabel(text: "conversionpage_subtitle".vipLocalized(),
                                        color: .gl_color(0xff5600),
                                        font: .title2Bold,
                                        alignment: .center)
    
    private lazy var priceView: PriceView = {
        let priceView = PriceView()
        priceView.handler = {[weak self] _ in
            guard let self else { return }
            self.showCurrentPriceType()
//            self.delegate?.startAction(self.priceType)
        }
        return priceView
    }()
    
    private lazy var reminderIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.imageOrMain("reminder_ring_27584", for: self.classForCoder)
        return imageView
    }()
    
    private lazy var reminderView: UIView = {
        let title = self.localized(key: "conversionpage_price_remind")
        let reminderView = PurchaseTrailReminderView(owner: self.delegate, enable: false, title: title)
        reminderView.titleLabel.adjustsFontSizeToFitWidth = true
        reminderView.titleLabel.textColor = .gW
        reminderView.titleLabel.font = .mediumAvenir(14.rpx)
        reminderView.titleLabel.numberOfLines = 2
        reminderView.switchView.onBackgroundView.backgroundColor = .gl_color(0xff5600)
        reminderView.layer.borderColor = UIColor.clear.cgColor
        reminderView.layer.borderWidth = 0.0
        reminderView.backgroundColor = .clear
        return reminderView
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .heavyAvenir(14.rpx)
        label.textColor = .gW
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let title = self.localized(key: "text_continue")
        let button = UIButton(title: title, color: .white, font: .heavyAvenir(20.rpx),
                              backgroundColor: .gl_color(0xff5600))
        button.rac_signal(for: .touchUpInside).subscribeNext {[weak self] _ in
            guard let self else { return }
            self.delegate?.startAction(self.priceType)
        }
        return button
    }()
    
    private lazy var featureView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = GLFrameSize1(16, 11)
        let features = [
            "conversionpage_feature_1".vipLocalized(),
            "conversionpage_feature_2".vipLocalized(),
            "conversionpage_feature_3".vipLocalized()
        ]
        for feature in features {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.alignment = .top
            hStack.spacing = GLFrameSize1(16, 10)
            let icon = UIImageView(image: UIImage.imageOrMain("feature_27616", for: Vip27616AContentView.classForCoder()))
            let label = UILabel(title: feature, color: .gW, font: .mediumAvenir(GLFrameSize1(20, 16)))
            label.numberOfLines = 0
            label.textAlignment = .left
            hStack.addArrangedSubview(icon)
            hStack.addArrangedSubview(label)
            icon.snp.makeConstraints { make in
                make.width.height.equalTo(GLFrameSize1(24, 16))
                make.top.equalTo(4.rpx)
            }
            stack.addArrangedSubview(hStack)
        }
        return stack
    }()
    
    private lazy var bottomActionView = Vip27601ABottomActionView(maxWidth: self.contentWidth) {[weak self] type in
        switch type {
        case .termOfUse:
            self?.delegate?.termsOfUseAction()
        case .privacyPolicy:
            self?.delegate?.privacyPolicyAction()
        case .restore:
            self?.delegate?.restoreAction()
        case .subscription:
            self?.delegate?.subscriptionAction()
        }
    }
}

class Vip27584AContentCenterView: UIView {
    private var view: UIView
    
    init(view: UIView) {
        self.view = view
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.gl_removeAllSubviews()
        self.gl_addSubviews([self.topView, self.view, self.bottomView])
        
        self.topView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.greaterThanOrEqualTo(GLFrameSize4(27.0, 25.0, 16.0, 16.0))
        }
        
        self.view.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(self.topView.snp.bottom)
        }
        
        self.bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
            make.height.equalTo(self.topView.snp.height).multipliedBy(2.0)
        }
    }
    
    func update(view: UIView) {
        self.view = view
        self.configUI()
    }
    
    private lazy var topView = UIView()
    private lazy var bottomView = UIView()
}

func glOpt<T>(_ iPad: T, _ iPhonex: T, _ iPhone8: T, _ iPhone5: T) -> T {
    if IsIPad {
        return iPad
    }
    
    if IsIPhoneX {
        return iPhonex
    }
    
    if IsIPhone5 {
        return iPhone5
    }
    
    return iPhone8
}

extension String {
    func vipLocalized(for aClass: AnyClass? = Vip27616AContentView.self, tabName: String = "Localizable27616") -> String {
        self.localized(for: aClass, tableName: tabName)
    }
}


