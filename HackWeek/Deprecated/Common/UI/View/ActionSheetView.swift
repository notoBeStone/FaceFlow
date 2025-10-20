//
//  ActionSheetView.swift
//  AINote
//
//  Created by Martin on 2024/11/18.
//

import UIKit
import SwiftUI
import GLResource
import GLUtils

enum ActionSheetItemType {
    case shareNote
    case deleteNote
    
    var title: String {
        switch self {
        case .shareNote:
            return ""
//            return GLMPLanguage.shareNote
        case .deleteNote:
//            return GLMPLanguage.deleteNote
            return ""
        }
    }
    
    var icon: String {
        switch self {
        case .shareNote:
            return "actionsheet_share_icon"
        case .deleteNote:
            return "actionsheet_share_delete"
        }
    }
    
    var textColor: Color {
        switch self {
        case .deleteNote:
            return .f4
        case .shareNote:
            return .g9
        }
    }
}

struct ActionSheetItem {
    let type: ActionSheetItemType
    let title: String
    let handler: ()->()
    
    init(type: ActionSheetItemType, title: String? = nil, handler: @escaping () -> Void) {
        self.type = type
        self.title = title ?? type.title
        self.handler = handler
    }
}

class ActionSheetView: BasePopUpView {
    let items: [ActionSheetItem]
    
    init(items: [ActionSheetItem]) {
        self.items = items
        super.init(frame: ScreenBounds)
        configUI()
        self.blankClickHandler = { [weak self] _ in
            self?.dismiss(animated: true, completion: {})
        }
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        let swiftUIView = ActionSheetContentView(items: items) { _ in
            self.dismiss(animated: true, completion: {})
        }
        self.contentView.addSwiftUI(viewController: GLHostingController(rootView: swiftUIView)) { make in
            make.edges.equalToSuperview()
        }
    }
    
    override var contentCormnerRadius: CGFloat {
        return 20.rpx
    }
}

struct ActionSheetContentView: View {
    let items: [ActionSheetItem]
    let handler: (_ item: ActionSheetItem)->()
    
    var body: some View {
        VStack (spacing: 18.rpx) {
            ZStack{}
                .frame(width: 54.rpx, height: 3.0)
                .background(Color.g3)
                .clipShape(Capsule())
            
            VStack(spacing: 0.0) {
                ForEach(Array(items.enumerated()), id: \.offset) { element in
                    HStack(alignment: .center, spacing: 10.rpx) {
                        Image(element.element.type.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30.rpx, height: 30.rpx)
                        
                        Text(element.element.title)
                            .font(.medium(17.rpx))
                            .foregroundColor(element.element.type.textColor)
                        ZerorSpacer()
                    }
                    .padding(.vertical, 18.rpx)
                    .overlay(alignment: .top) {
                        if element.offset != 0 {
                            GLLineView(color: Color.g2N, lineWidth: 1)
                        }
                    }
                    .padding(.horizontal, Consts.contentLeading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.handler(element.element)
                        element.element.handler()
                    }
                }
            }
        }
        .padding(.top, 12.rpx)
        .padding(.bottom, Consts.safeBottom + 20.rpx)
        .ignoresSafeArea()
    }
}
