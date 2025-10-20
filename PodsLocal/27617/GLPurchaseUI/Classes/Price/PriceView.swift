//
//  PriceView.swift
//  Vip27584
//
//  Created by Martin on 2024/8/22.
//

import UIKit
import GLUtils
import GLResource

class PriceView: UIView {
    private(set) var selectedType: Price27617Type = .default {
        didSet {
            if self.selectedType != oldValue {
                self.showSelected()
                self.handler?(self.selectedType)
            }
        }
    }
    var handler: ((_ type: Price27617Type)->())?
    
    init() {
        super.init(frame: .zero)
        configUI()
        showSelected()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.gl_addSubviews(self.itemViews)
        
        var lastView: UIView? = nil
        self.itemViews.forEach { itemView in
            itemView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(GLFrameSize1(99.rpx, 89.rpx))
                make.bottom.equalTo(0)
                if let lastView {
                    make.leading.equalTo(lastView.snp.trailing).offset(GLFrameSize1(12.rpx, 10.rpx))
                    make.width.equalTo(lastView.snp.width)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            lastView = itemView
        }
        
        lastView?.snp.makeConstraints({ make in
            make.trailing.equalToSuperview()
        })
    }
    
    func showSelected() {
        self.itemViews.forEach {
            $0.selected = self.selectedType == $0.type
        }
    }
    
    func showPrice() {
        self.itemViews.forEach {
            $0.showPrice()
        }
    }
    
    // MARK: - Lazy load
    private lazy var itemViews: [PriceItemView] = {
        let views: [PriceItemView] = Price27617Type.allCases.map { type in
            let itemView = PriceItemView(type: type)
            itemView.handler = {[weak self] in
                self?.selectedType = type
            }
            return itemView
        }
        return views
    }()
}

class PriceItemView: UIView {
    let type: Price27617Type
    var selected: Bool = false {
        didSet {
            if oldValue != self.selected {
                self.showSelected()
            }
        }
    }
    var handler: (()->())?
    
    init(type: Price27617Type) {
        self.type = type
        super.init(frame: .zero)
        configUI()
        showSelected()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.addSubview(self.contentView)
        self.contentView.gl_addSubviews([self.centerView, self.button])
        self.centerView.gl_addSubviews([self.topLabel, self.bottomLabel, self.iconView])
        
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(20.0)
            make.top.equalTo(16.rpx)
        }
        
        self.topLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        self.bottomLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.top.equalTo(self.topLabel.snp.bottom).offset(3.0)
        }
        
        self.iconView.snp.makeConstraints { make in
            make.width.height.equalTo(18.rpx)
            make.trailing.centerY.equalToSuperview()
        }
        
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.button.rac_signal(for: .touchUpInside).subscribeNext {[weak self] _ in
            self?.handler?()
        }
        
        if let nopaymentView {
            self.addSubview(nopaymentView)
            nopaymentView.snp.makeConstraints { make in
                make.centerY.equalTo(self.snp.top)
                make.trailing.equalToSuperview()
            }
        }
    }
    
    func showPrice() {
        let text: String
        let topText = self.type.price?.price ?? "--"
        switch self.type {
            case .year:
                text = "conversionpage_price_1year".vipLocalized()
                
            case .week:
                text = "conversionpage_price_1week".vipLocalized()
        }
        self.bottomLabel.text = text
        self.topLabel.text = topText
    }
    
    func showSelected() {
        let bgColor: UIColor
        let borderWidth: Double
        let borderColor: UIColor
        if self.selected {
            borderWidth = 3.0
            borderColor = .gl_color(0xff5600)
            bgColor = .gl_color(0xff5600).withAlphaComponent(0.08)
        } else {
            borderWidth = 1.5
            borderColor = .gW.withAlphaComponent(0.29)
            bgColor = .clear
        }
        self.contentView.layer.borderColor = borderColor.cgColor
        self.contentView.layer.borderWidth = borderWidth
        self.contentView.backgroundColor = bgColor
        self.iconView.image = UIImage.imageOrMain(self.selected ? "price_select_27584" : "price_unselect_27584", for: self.classForCoder)
        self.button.isUserInteractionEnabled = !self.selected
        nopaymentView?.selected = self.selected
    }
    
    // MARK: - Lazy load
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16.0
        view.clipsToBounds = true
        return view
    }()
    private lazy var centerView = UIView()
    private lazy var topLabel: UILabel = {
        let label = UILabel(color: .gW, font: .heavyAvenir(18.rpx))
        let text: String
        
        switch self.type {
            case .year:
                text = self.type.price?.price ?? "--"
            case .week:
                text = self.type.price?.price ?? "--"
        }
        label.text = text
        return label
    }()
    
    private lazy var bottomLabel = UILabel(color: .gW, font: .mediumAvenir(16.rpx))
    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    private lazy var button = UIButton()
    private lazy var nopaymentView: NoPaymentView? = {
        return nil
    }()
}

class NoPaymentView: UIView {
    var selected: Bool = false {
        didSet {
            showCurrentSelect()
        }
    }
    
    init() {
        super.init(frame: .zero)
        configUI()
        showCurrentSelect()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.gl_addSubviews([leftBgView, rightBgView, iconView, titleLabel])
        
        leftBgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        rightBgView.snp.makeConstraints { make in
            make.leading.equalTo(self.leftBgView.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(self.leftBgView.snp.width)
        }
        
        let leading = 10.rpx
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(20.rpx)
            make.centerY.equalToSuperview()
            make.leading.equalTo(leading)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.iconView.snp.trailing).offset(6.rpx)
            make.trailing.equalToSuperview().inset(leading)
            make.top.equalTo(6.rpx)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.leftBgView.gl_roundCorners([.topLeft, .bottomLeft], radius: 8.rpx)
        self.rightBgView.gl_roundCorners([.topRight], radius: 16.rpx)
    }
    
    private func showCurrentSelect() {
        let textColor: UIColor = selected ? .gl_color(0xff5600) : .gW
        let iconName: String = selected ? "nopayment_select" : "nopayment_unselect"
        let bgColor: UIColor = selected ? .gl_color(0xff5600) : .gW
        
        titleLabel.textColor = textColor
        iconView.image = UIImage.imageOrMain(iconName, for: self.classForCoder)
        leftBgView.backgroundColor = bgColor
        rightBgView.backgroundColor = bgColor
    }
    
    private lazy var leftBgView = UIView()
    private lazy var rightBgView = UIView()
    
    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(title: "conversionpage_nopaymentnow".vipLocalized(), color: nil, font: .buttonTextMedium)
        return label
    }()
}
