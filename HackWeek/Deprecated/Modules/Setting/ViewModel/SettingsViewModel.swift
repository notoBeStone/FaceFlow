//
//  SettingsViewModel.swift
//  PictureThis
//
//  Created by user on 2024/8/7.
//

import SwiftUI
import GLMP
import AppModels
import GLCore
import GLWebImageExtension
import GLConfig_Extension

enum SettingGroupType {
    case membership
    case general
    case support
    case account
    case legal
    case about
    case debug
    
    var title: String {
        switch self {
        case .membership:
            return GLMPLanguage.setting_cell_title_membership
        case .general:
            return GLMPLanguage.setting_general_settings
        case .support:
            return GLMPLanguage.setting_support
        case .account:
            return GLMPLanguage.text_setting_account
        case .legal:
            return GLMPLanguage.setting_legal
        case .about:
            return GLMPLanguage.setting_about_the_app
        case .debug:
            return "debug"
        }
    }
}


enum SettingItemType: String, CaseIterable {
    case premiumService
    case restore
    case manageMembership
    case setLanguage
    case careNotification
    case allowToAccess
    case autoSavePhotos
    case clearCache
    case encourageUs
    case help
    case contactUs
    case snapTips
    case manageAccount
    case login
    case deleteAccount
    case privacyPolicy
    case termsOfUse
    case appInfo
    case rateApp
    case tellFriends
    case debugDeleteDeviceId
    case debugClearCache
    case debugVipPageTest
    
    var group: SettingGroupType {
        switch self {
        case .premiumService, .restore, .manageMembership:
            return .membership
        case .setLanguage,
                .careNotification,
                .allowToAccess,
                .autoSavePhotos,
                .clearCache:
            return .general
        case .encourageUs, .help, .contactUs, .snapTips:
            return .support
        case .manageAccount, .login, .deleteAccount:
            return .account
        case .privacyPolicy, .termsOfUse:
            return .legal
        case .appInfo, .rateApp, .tellFriends:
            return .about
        case .debugDeleteDeviceId, .debugClearCache, .debugVipPageTest:
            return .debug
        }
    }
    
    var key: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .premiumService:
            return "icon_premium_outlined"
        case .restore:
            return "icon_turn_outlined_regular"
        case .manageMembership:
            return "icon_manage_account_outlined"
        case .setLanguage:
            return "icon_language_outlined"
        case .careNotification:
            return "icon_notification_outlined"
        case .allowToAccess:
            return "icon_access_outlined"
        case .autoSavePhotos:
            return "icon_pic_outlined_regular"
        case .clearCache:
            return "icon_clear_outlined"
        case .encourageUs:
            return "icon_yes_outlined"
        case .help:
            return "icon_help_outlined_regular"
        case .contactUs:
            return "icon_suggestion_outlined"
        case .snapTips:
            return "icon_camera_outlined_regular"
        case .manageAccount:
            return "icon_manage_membership_outlined"
        case .login, .deleteAccount:
            return "icon_log_in_outlined"
        case .privacyPolicy:
            return "icon_privacy_policy_outlined"
        case .termsOfUse:
            return "icon_terms_outlined"
        case .appInfo:
            return "icon_info_outlined_regular"
        case .rateApp:
            return "icon_rate_outlined"
        case .tellFriends:
            return "icon_share_outlined_regular"
        case .debugClearCache, .debugDeleteDeviceId, .debugVipPageTest:
            return "icon_share_outlined_regular"
        }
    }
    
    var title: String {
        switch self {
        case .premiumService:
            return GLMPLanguage.setting_cell_my_premium_service
        case .restore:
            return GLMPLanguage.text_restore_membership
        case .manageMembership:
            return GLMPLanguage.text_manage_subscription_title_a
        case .setLanguage:
            return GLMPLanguage.text_set_language
        case .careNotification:
            return GLMPLanguage.reminder_care_notification
        case .allowToAccess:
            return GLMPLanguage.text_allow_to_access
        case .autoSavePhotos:
            return GLMPLanguage.setting_auto_save
        case .clearCache:
            return GLMPLanguage.text_cache
        case .encourageUs:
            return GLMPLanguage.setting_text_encourage_us
        case .help:
            return GLMPLanguage.text_help
        case .contactUs:
            return GLMPLanguage.text_contact_us
        case .snapTips:
            return GLMPLanguage.text_snap_tips
        case .manageAccount:
            return GLMPLanguage.settings_manageaccount_text
        case .login:
            return "\(GLMPLanguage.text_login) / \(GLMPLanguage.text_sign_up)"
        case .deleteAccount:
            return GLMPLanguage.text_delete_account
        case .privacyPolicy:
            return GLMPLanguage.protocol_privacypolicy
        case .termsOfUse:
            return GLMPLanguage.protocol_termsofuse
        case .appInfo:
            return GLMPLanguage.setting_app_info
        case .rateApp:
            return GLMPLanguage.text_rate_app
        case .tellFriends:
            return GLMPLanguage.text_home_tell_friends
        case .debugClearCache:
            return "清楚缓存"
        case .debugVipPageTest:
            return "转化页测试"
        case .debugDeleteDeviceId:
            return "删除设备 ID"
        }
    }
}


enum SettingsCellStyle: Hashable {
    case indicator(text: String?)
    case toggle(on: Bool)
}

class SettingsItemViewModel: ObservableObject {
    
    let key: String
    
    var iconName: String
    
    var title: String
    
    var subTitle: String?
    
    @Published var style: SettingsCellStyle
    
    
    init(key: String, iconName: String, title: String, subTitle: String? = nil, style: SettingsCellStyle = .indicator(text: nil)) {
        self.key = key
        self.iconName = iconName
        self.title = title
        self.subTitle = subTitle
        self.style = style
    }
}

extension SettingsItemViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(iconName)
        hasher.combine(title)
        hasher.combine(subTitle)
        hasher.combine(style)
    }
    
    static func == (lhs: SettingsItemViewModel, rhs: SettingsItemViewModel) -> Bool {
        return lhs.key == rhs.key &&
        lhs.iconName == rhs.iconName &&
        lhs.title == rhs.title &&
        lhs.subTitle == rhs.subTitle &&
        lhs.style == rhs.style
    }
}


class SettingsGroupViewModel: ObservableObject {
    @Published var name: String
    
    var items: [SettingsItemViewModel]
    
    init(name: String, items: [SettingsItemViewModel]) {
        self.name = name
        self.items = items
    }
}

//实现Identifiable
extension SettingsGroupViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}


class SettingsViewModel: ObservableObject {
    @Published var groups: [SettingsGroupViewModel] = []
    
    init() {
        registerNotification()
        refreshData()
        
    }
    
    private func refreshData() {
        var groups = [
            Self.getMembershipGroup(),
            Self.getGeneralGroup(),
            Self.getSupportGroup(),
            Self.getAccountGroup(),
            Self.getLegalGroup(),
            Self.getAboutGroup()
        ]
        
        if !GL().GLConfig_currentEnvironmentIsProduction() {
            groups.append(Self.getDebugGroup())
        }
        self.groups = groups
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GLMediator.kUserUpdateNotification), object: nil, queue: .main) { [weak self] notification in
            self?.refreshData()
        }
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GLMediator.kUserDeleteNotification), object: nil, queue: .main) { [weak self] notification in
//            self?.refreshData()
//        }
    }
    
    
    public func getItem(with key: String) -> SettingsItemViewModel? {
        let items = groups.flatMap { $0.items }
        return items.first { $0.key == key }
    }
    
    
    //Menbership
    private static func getMembershipGroup() -> SettingsGroupViewModel {
        
        let group: SettingGroupType = .membership
        var items: [SettingsItemViewModel] = []
        
        let premiumType: SettingItemType = .premiumService
        var status: String = GLMPLanguage.setting_cell_my_premium_service_free
        if let vipInfo = GLMPAccount.getVipInfo() {
            switch vipInfo.vipLevel {
            case .GOLD:
                status = GLMPLanguage.setting_cell_my_premium_service_gold
            case .PLATINUM:
                status = GLMPLanguage.setting_cell_my_premium_service_gold
            case .PRO:
                status = GLMPLanguage.setting_cell_my_premium_service_gold
            case .PLUS:
                status = GLMPLanguage.setting_cell_my_premium_service_gold
            case .FAMILY:
                status = GLMPLanguage.setting_cell_my_premium_service_gold
            default:
                status = IsVIP() ? GLMPLanguage.setting_cell_my_premium_service_gold : GLMPLanguage.setting_cell_my_premium_service_free
            }
        }
        
        let premiumSubTitle = GLMPLanguage.setting_cell_my_premium_service_membership + " \(status)"
        let premium = SettingsItemViewModel(key: premiumType.key, iconName: premiumType.iconName, title: premiumType.title, subTitle: premiumSubTitle)
        items.append(premium)
        
        if GLMPAccount.isVip() {
            items.append(SettingsItemViewModel(key: SettingItemType.manageMembership.key, iconName:  SettingItemType.manageMembership.iconName, title:  SettingItemType.manageMembership.title))
        } else {
            items.append(SettingsItemViewModel(key: SettingItemType.restore.key, iconName:  SettingItemType.restore.iconName, title:  SettingItemType.restore.title))
        }
        return SettingsGroupViewModel(name: group.title, items: items)
    }
    
    //General
    static private func getGeneralGroup() -> SettingsGroupViewModel {
        let group: SettingGroupType = .general
        var items: [SettingsItemViewModel] = []
        
//        items.append(SettingsItemViewModel(key: SettingItemType.setLanguage.key,
//                                           iconName: SettingItemType.setLanguage.iconName,
//                                           title: SettingItemType.setLanguage.title))
        
//        items.append(SettingsItemViewModel(key: SettingItemType.careNotification.key,
//                                           iconName: SettingItemType.careNotification.iconName,
//                                           title: SettingItemType.careNotification.title))
        
//        items.append(SettingsItemViewModel(key: SettingItemType.allowToAccess.key,
//                                           iconName: SettingItemType.allowToAccess.iconName,
//                                           title: SettingItemType.allowToAccess.title))
        
        
        
//        let autoSave = SettingsCache.enableAutoSaveToAlbums
//        let savePhotoModel = SettingsItemViewModel(key: SettingItemType.autoSavePhotos.key,
//                                                     iconName: SettingItemType.autoSavePhotos.iconName,
//                                                     title: SettingItemType.autoSavePhotos.title, style: .toggle(on: autoSave))
//        items.append(savePhotoModel)
        
        
        
        let clearCacheModel = SettingsItemViewModel(key: SettingItemType.clearCache.key,
                                                     iconName: SettingItemType.clearCache.iconName,
                                                     title: SettingItemType.clearCache.title,
                                                     style: .indicator(text: nil))
        items.append(clearCacheModel)
        
        // 计算总缓存大小
        calculateTotalCacheSize { totalSize in
            clearCacheModel.style = .indicator(text: GLMPAppUtil.stringFromSize(CGFloat(totalSize)))
        }
        
        return SettingsGroupViewModel(name: group.title, items: items)
    }
    
    // 添加缓存计算方法
    static private func calculateTotalCacheSize(completion: @escaping (Int) -> Void) {
        let group = DispatchGroup()
        var totalSize: Int = 0
        
        // 计算图片缓存
        group.enter()
        GL().WebImage_CalculateSize({ _, imageSize in
            totalSize += Int(imageSize)
            group.leave()
        })
        
        // 所有计算完成后回调
        group.notify(queue: .main) {
            completion(totalSize)
        }
    }
    
    
    
    //Support
    static private func getSupportGroup() -> SettingsGroupViewModel {
        let group: SettingGroupType = .support
        let unsurpportTypes: [SettingItemType] = [
            .help,
            .snapTips
        ]
        let items: [SettingsItemViewModel] = SettingItemType.allCases.filter { $0.group == group }.compactMap { type in
            if unsurpportTypes.contains(type) {
                return nil
            }
            return SettingsItemViewModel(key: type.key, iconName: type.iconName, title: type.title)
        }
        return SettingsGroupViewModel(name: group.title, items: items)
    }
    
    
    //Account
    static private func getAccountGroup() -> SettingsGroupViewModel {
        let group: SettingGroupType = .account
        let itemType: SettingItemType = .deleteAccount
        return SettingsGroupViewModel(name: group.title, items: [SettingsItemViewModel(key: itemType.key, iconName: itemType.iconName, title: itemType.title)])
    }
    
    //Legal
    static private func getLegalGroup() -> SettingsGroupViewModel {
        let group: SettingGroupType = .legal
        let items = SettingItemType.allCases.filter { $0.group == group }.compactMap { type in
            SettingsItemViewModel(key: type.key, iconName: type.iconName, title: type.title)
        }
        return SettingsGroupViewModel(name: group.title, items: items)
    }
    
    
    //About
    static private func getAboutGroup() -> SettingsGroupViewModel {
        let group: SettingGroupType = .about
        let items = SettingItemType.allCases.filter { $0.group == group }.compactMap { type in
            SettingsItemViewModel(key: type.key, iconName: type.iconName, title: type.title)
        }
        return SettingsGroupViewModel(name: group.title, items: items)
    }
    
    //Debug
    static private func getDebugGroup() -> SettingsGroupViewModel {
        let group: SettingGroupType = .debug
        let items = SettingItemType.allCases.filter { $0.group == group }.compactMap { type in
            SettingsItemViewModel(key: type.key, iconName: type.iconName, title: type.title)
        }
        return SettingsGroupViewModel(name: group.title, items: items)
    }
    
}



extension TemperatureUnit {
    
    var unitText: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
    
    var title: String {
        switch self {
        case .celsius:
            return GLMPLanguage.settings_general_title_celsius
        case .fahrenheit:
            return GLMPLanguage.settings_general_title_fahrenheit
        }
    }
}

extension MeasurementSystem {
    var systemName: String {
        switch self {
        case .metric:
            return GLMPLanguage.settings_general_title_metric
        case .imperial:
            return GLMPLanguage.settings_general_title_uk
        }
    }
}

