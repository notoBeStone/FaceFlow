//
//  Vip27584ABottomActiionView.swift
//  Vip27584
//
//  Created by Martin on 2024/3/27.
//

import UIKit
import GLPurchaseUI
import GLUtils

enum BottomActionType: CaseIterable {
    case termOfUse
    case privacyPolicy
    case subscription
    case restore
    
    static var gapText: String {
        return "  |  "
    }
    
    var title: String {
        switch self {
        case .termOfUse:
            return "vipcommon_terms_of".localized(for: GLOCVipBaseViewController.self, tableName: "Localizable")
        case .privacyPolicy:
            return "vipcommon_privacy_policy".localized(for: GLOCVipBaseViewController.self, tableName: "Localizable")
        case .subscription:
            return "vipcommon_subscription_terms".localized(for: Vip27601ABottomActionView.self, tableName: "Localizable27617")
        case .restore:
            return "vipcommon_restore".localized(for: GLOCVipBaseViewController.self, tableName: "Localizable")
        }
    }
}

class Vip27601ABottomActionView: UIView {
    let font: UIFont
    var handler: (_ type: BottomActionType)->()
    
    init(maxWidth: Double, handler: @escaping (_: BottomActionType) -> Void) {
        self.handler = handler
        self.font = Self.bottomActionButtonFont(maxWidth: maxWidth)
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        var views: [UIView] = []
        
        BottomActionType.allCases.enumerated().forEach {
            if $0.offset != 0 {
                views.append(self.createGapView())
            }
            views.append(self.createButton(type: $0.element))
        }
        
        var lastView: UIView? = nil
        
        views.forEach { view in
            self.addSubview(view)
            view.snp.makeConstraints { make in
                if let lastView = lastView {
                    make.leading.equalTo(lastView.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                make.centerY.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview()
            }
            lastView = view
        }
        
        lastView?.snp.makeConstraints({ make in
            make.trailing.equalToSuperview()
        })
    }
    
    private func createButton(type: BottomActionType) -> UIView {
        let button = UIButton(title: type.title, color: .gl_color(0x666666), font: self.font)
        button.rac_signal(for: .touchUpInside).subscribeNext {[weak self] _ in
            self?.handler(type)
        }
        return button
    }
    
    private func createGapView() -> UIView {
        let text = UILabel(text: BottomActionType.gapText, color: .gl_color(0x666666), font: self.font)
        return text
    }
    
    private func bottomActionTextType(_ type: BottomActionType) -> String {
        type.title
    }
    
    private static func bottomActionButtonFont(maxWidth: Double) -> UIFont {
        let fontSize = 11.0
        
        let texts = BottomActionType.allCases.map {$0.title}
        let text = texts.joined(separator: BottomActionType.gapText)
        let font = UIFont.regular(fontSize)
        let width = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        if maxWidth >= width {
            return font
        }
        
        let scaleFontSize = ((maxWidth / width) * fontSize).gl_reserve(decimal: 0, mode: .floor)
        return UIFont.regular(scaleFontSize)
    }
}
