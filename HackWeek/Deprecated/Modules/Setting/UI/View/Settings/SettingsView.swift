//
//  SettingsView.swift
//  PictureThis
//
//  Created by user on 2024/8/7.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLWidget
import ExytePopupView

#if DEBUG
struct Settings_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(), actionModel: SettingsActionModel())
    }
}
#endif

class SettingsActionModel: ObservableObject {
    var backAction = PassthroughSubject<Void, Never>()
    var itemAction = PassthroughSubject<SettingsItemViewModel, Never>()
    var itemSwitchAction = PassthroughSubject<SettingsItemViewModel, Never>()
}

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var actionModel: SettingsActionModel
    
    var body: some View {
        GLNavigationBar {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.groups, id: \.id) { group in
                        SettingsGroupView(group: group)
                    }
                }
                .padding(.bottom, 30.rpx)
            }
            .background(Color.g0)
            .environmentObject(viewModel)
            .environmentObject(actionModel)
        }
        .setBackLeadingItem({
            actionModel.backAction.send()
        })
        .setTitle(GLMPLanguage.text_setting)
        .navigationBarBackground {
            Color.g0
        }
    }
    
    func updateBottomSheetParams<PopupContent: View>(_ params: Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters {
        params
            .position(.bottom)
            .closeOnTap(false)
            .closeOnTapOutside(true) //用于控制点击外部是否关闭弹窗
            .isOpaque(true) //用于控制是否是present形式弹出，可用于遮盖底部tabbar
            .backgroundColor(.black.opacity(0.4))
            .useKeyboardSafeArea(true)
    }
}

struct SettingsGroupView: View {
    @ObservedObject var group: SettingsGroupViewModel
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var actionModel: SettingsActionModel
    
    var body: some View {
        VStack(spacing: 16.rpx) {
            
            Text(group.name)
                .textStyle(.headlineBold)
                .foregroundColor(.g9)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ForEach(Array(group.items.enumerated()), id: \.offset) { index, item in
                    SettingsItemView(item: item)
                        .padding(.horizontal, 16.rpx)
                        .onTapGesture {
                            if case .indicator(_) = item.style {
                                actionModel.itemAction.send(item)
                            }
                        }
                    
                    if index != group.items.count - 1 {
                        GLLineView(color: Color.g2N, lineWidth: 0.5)
                            .padding(.horizontal, 16.rpx)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.gW)
            .cornerRadius(8.rpx)
            .gl_shadow(style: .sD3)
        }
        .padding(16.rpx)
    }
}


struct SettingsItemView:View {
    @ObservedObject var item: SettingsItemViewModel
    @EnvironmentObject var actionModel: SettingsActionModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.rpx) {
            HStack(alignment: .top, spacing: 8.rpx) {
                HStack(alignment: .top, spacing: 10.rpx) {
                    Image(item.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.g6)
                        .frame(width: 20.rpx, height: 20.rpx)
                }
                .padding(.vertical, 1.rpx)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(item.title)
                        .textStyle(.footnoteMedium)
                        .foregroundColor(.g9)
                    
                    if let subTitle = item.subTitle, !subTitle.isEmpty {
                        Text(subTitle)
                            .textStyle(.footnoteRegular)
                            .foregroundColor(.g5)
                    }
                }
                .layoutPriority(1)
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                switch item.style {
                case .indicator(let text):
                    VStack {
                        HStack(alignment: .center, spacing: 4.rpx) {
                            if let text = text {
                                Text(text)
                                    .textStyle(.footnoteRegular)
                                    .foregroundColor(.g6)
                                    .lineLimit(1)
                            }
                            
                            Image("icon_goto_outlined_heavy")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 16.rpx, height: 16.rpx)
                                .foregroundColor(.g5)
                        }
                    }
                case .toggle(_):
                    Rectangle()
                        .frame(width: 50.rpx, height: 22.rpx)
                        .foregroundColor(.clear)
                        .overlay(
                            Toggle("", isOn: Binding(get: {
                                if case .toggle(let on) = item.style {
                                    return on
                                }
                                return false
                            }, set: { on in
//                                item.style = .toggle(on: on)
                                actionModel.itemSwitchAction.send(item)
                            }))
                        )
                    
                }
            }
            
        }
        .padding(.vertical, 16.rpx)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

