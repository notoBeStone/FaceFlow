//
//  BottomSheet.swift
//  AINote
//
//  Created by user on 2024/5/13.
//

import UIKit
import GLUtils
import GLResource
import GLAnalyticsUI

class BottomSheet: AlertBaseView {
    
    private var title: String?
    private var message: String?
    private var from: String
    
    private var actionItems: [BottomSheetItem] = []
    private var cancelItem: BottomSheetItem?
    
    public init(title: String? = nil, message: String? = nil, from: String) {
        self.title = title
        self.message = message
        self.from = from
        
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let _ = superview {
            trackingShow()
        } else {
            trackingHide()
        }
    }
    
    
    public func addTitle(_ title: String, style: UIAlertAction.Style, handler: (() -> Void)?) {
        let item = BottomSheetItem(title: title, style: style)
        if style == .cancel {
            self.cancelItem = item
        } else {
            self.actionItems.append(item)
        }
        
        item.handler = { [weak self] in
            handler?()
            self?.dismiss(animated: true)
        }
    }
    
    public func addAttributedString(_ attributedString: NSAttributedString, style: UIAlertAction.Style, handler: (() -> Void)?) {
        let item = BottomSheetItem(attributedTitle: attributedString, style: style)
        if style == .cancel {
            self.cancelItem = item
        } else {
            self.actionItems.append(item)
        }
        
        item.handler = { [weak self] in
            handler?()
            self?.dismiss(animated: true)
        }
    }
    
    public func show() {
        contentView.backgroundColor = .clear
        contentView.addSubview(alertContentView)
        alertContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        super.show(animated: true)
        
        blankClikHandler = { [weak self] sender in
            self?.blanckClicked()
        }
    }
    
    private func blanckClicked() {
        dismiss(animated: true)
    }
        
    // MARK: - lazy load
        
    private lazy var alertContentView: BottomSheetContentView = {
        let view = BottomSheetContentView(title: title ?? "", message: message ?? "", actionItems: actionItems, cancelItem: cancelItem)
        return view
    }()
}

extension BottomSheet: GLAPageProtocol {
    var pageName: String? {
        return from
    }
}


fileprivate class BottomSheetItem {
    var title: String?
    var attributedTitle: NSAttributedString?
    var style: UIAlertAction.Style
    var handler: (() -> Void)?
    
    init(title: String? = nil, attributedTitle: NSAttributedString? = nil, style: UIAlertAction.Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.attributedTitle = attributedTitle
        self.style = style
        self.handler = handler
    }
}

//MARK: - BottomSheetItemView

fileprivate class BottomSheetItemView: UIView {
   
    let item: BottomSheetItem
    
    init(item: BottomSheetItem) {
        self.item = item
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //lazy
    
    private lazy var button: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 5.rpx, left: 16.rpx, bottom: 5.rpx, right: 16.rpx)
        if let attributedTitle = item.attributedTitle {
            btn.setAttributedTitle(attributedTitle, for: .normal)
        } else {
            btn.setTitle(item.title, for: .normal)
            
            var font: UIFont = .bodyRegular
            if item.style == .cancel {
                font = .bodyMedium
            }
            btn.titleLabel?.font = font
            
            var textColor: UIColor = .p5
            if item.style == .destructive {
                textColor = .red
            }
            btn.setTitleColor(textColor, for: .normal)
            
        }
        
        
        let selectColor = UIColor.gl_colorDynamic(light: 0xcacaca, dark: 0x383636)
        let normalImage = UIImage(color: .clear)
        let selectImage = UIImage(color: selectColor)
        btn.setBackgroundImage(normalImage, for: .normal)
        btn.setBackgroundImage(selectImage, for: .highlighted)
        btn.setBackgroundImage(selectImage, for: .selected)
        
        btn.gl_controlTapAction { [weak self] sender in
            self?.item.handler?()
        }
        
        return btn
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        if let attributedTitle = item.attributedTitle {
            label.attributedText = attributedTitle
        } else {
            var font: UIFont = .regular(20)
            if item.style == .cancel {
                font = .bold(20)
            }
            label.font = font
            
            var textColor: UIColor = .gl_color(0x1BB38D)
            if item.style == .destructive {
                textColor = .red
            }
            label.textColor = textColor
            
            label.text = item.title
        }
        return label
    }()
}

//MARK: - BottomSheetHeaderView

fileprivate class BottomSheetHeaderView: UIView {
    
    private var title: String
    private var message: String
    
    init?(title: String, message: String) {
        guard !title.isEmpty || !message.isEmpty else {
            return nil
        }
        self.title = title
        self.message = message
        super.init(frame: .zero)
        
        setUI()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        if let titleLabel = titleLabel {
            addSubview(titleLabel)
        }
        if let messageLabel = messageLabel {
            addSubview(messageLabel)
        }
    }
    
    private func setConstraints() {
        let xEdge: CGFloat = 16.rpx
        var topEdge: CGFloat = 12.rpx
        var upperView: UIView?
        
        if let titleLabel = titleLabel {
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(xEdge)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(topEdge)
            }
            upperView = titleLabel
            topEdge = 8.rpx
        }
        
        if let messageLabel = messageLabel {
            messageLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(xEdge)
                make.centerX.equalToSuperview()
                if let upperView = upperView {
                    make.top.equalTo(upperView.snp.bottom).offset(topEdge)
                } else {
                    make.top.equalToSuperview().offset(topEdge)
                }
            }
            upperView = messageLabel
        }
        
        var bottomEdge: CGFloat = 12.rpx
        if titleLabel != nil && messageLabel != nil {
            bottomEdge = 24.rpx
        }
        
        upperView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(bottomEdge)
        }
    }
    
    private lazy var titleLabel: UILabel? = {
        guard !title.isEmpty else { return nil }
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .g9
        label.font = .medium(18.rpx)
        label.text = title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var messageLabel: UILabel? = {
        guard !message.isEmpty else { return nil }
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gl_colorDynamic(light: 0x788056, dark: 0xa2a591)
        label.font = .light(14)
        label.text = message
        label.textAlignment = .center
        return label
    }()
}


//MARK: - BottomSheetSectionView

fileprivate class BottomSheetSectionView: UIView {
    private var items: [BottomSheetItem]
    private var itemViews: [BottomSheetItemView] {
        didSet {
            setUI()
        }
    }
    
    init(items: [BottomSheetItem]) {
        self.items = items
        self.itemViews = items.map { BottomSheetItemView(item: $0) }
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        var preView: UIView?
        
        for (index, obj) in itemViews.enumerated() {
            if index != 0 {
                let line = self.line()
                addSubview(line)
                line.snp.makeConstraints { make in
                    make.trailing.leading.equalToSuperview()
                    if let preView = preView {
                        make.top.equalTo(preView.snp.bottom)
                    } else {
                        make.top.equalToSuperview()
                    }
                    make.height.equalTo(0.6)
                }
                preView = line
            }
            addSubview(obj)
            obj.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                if let preView = preView {
                    make.top.equalTo(preView.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.height.greaterThanOrEqualTo(58.rpx)
            }
            preView = obj
        }
        
        preView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        clipsToBounds = true
    }
    
    func line() -> UIView {
        let line = UIView()
        line.backgroundColor = .gl_colorDynamic(light: 0xcacaca, dark: 0x383636)
        return line
    }
}


//MARK: - BottomSheetContentView

fileprivate class BottomSheetContentView: UIView {
    private var title: String
    private var message: String
    private var actionItems: [BottomSheetItem]
    private var cancelItem: BottomSheetItem?
    
    private lazy var headerView: BottomSheetHeaderView? = {
        guard !title.isEmpty || !message.isEmpty else { return nil }
        let view = BottomSheetHeaderView(title: title, message: message)
        view?.backgroundColor = .gl_colorDynamic(light: 0xffffff, dark: 0x1f1e1e)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .gl_colorDynamic(light: 0xffffff, dark: 0x1f1e1e)
        view.layer.cornerRadius = 16.0
        view.clipsToBounds = true
        
        var upperView: UIView?
        
        if let headerView = headerView {
            view.addSubview(headerView)
            headerView.snp.makeConstraints { make in
                make.leading.trailing.top.equalToSuperview()
            }
            upperView = headerView
        }
        
        if let contentSectionView = self.contentSectionView {
            if let upView = upperView {
                let line: UIView = contentSectionView.line()
                view.addSubview(line)
                line.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(upView.snp.bottom)
                    make.height.equalTo(0.6)
                }
                upperView = line
            }
            view.addSubview(contentSectionView)
            contentSectionView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                if let upperView = upperView {
                    make.top.equalTo(upperView.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }
            upperView = contentSectionView
        }
        upperView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var contentSectionView: BottomSheetSectionView? = {
        guard !actionItems.isEmpty else { return nil }
        return BottomSheetSectionView(items: actionItems)
    }()
    
    private lazy var cancelSectionView: BottomSheetSectionView? = {
        guard let cancelItem = cancelItem else { return nil }
        let view = BottomSheetSectionView(items: [cancelItem])
        view.backgroundColor = .gl_colorDynamic(light: 0xffffff, dark: 0x1f1e1e)
        view.layer.cornerRadius = 16.0
        return view
    }()
    
    init(title: String, message: String, actionItems: [BottomSheetItem], cancelItem: BottomSheetItem?) {
        self.title = title
        self.message = message
        self.actionItems = actionItems
        self.cancelItem = cancelItem
        super.init(frame: .zero)
        setUI()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(contentView)
        if let cancelSectionView = cancelSectionView {
            addSubview(cancelSectionView)
        }
    }
    
    private func setConstraint() {
        let xEdge: CGFloat = 8.0
        contentView.snp.makeConstraints { make in
            make.leading.equalTo(xEdge)
            make.top.centerX.equalToSuperview()
        }
        
        var upperView = contentView
        if let cancelSectionView = cancelSectionView {
            cancelSectionView.snp.makeConstraints { make in
                make.leading.equalTo(xEdge)
                make.centerX.equalToSuperview()
                make.top.equalTo(upperView.snp.bottom).offset(8.0)
            }
            upperView = cancelSectionView
        }
        
        upperView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8.0 + GLScreen.safeBottom)
        }
    }
}
