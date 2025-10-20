//
//  SettingsViewController.swift
//  PictureThis
//
//  Created by user on 2024/8/7.
//

import SwiftUI
import Combine
import GLCore
import GLResource
import GLUtils
import GLWidget
import GLAnalyticsUI
import GLMP
import AppConfig
import GLConfig
import GLModules
import GLShareExtension
import GLAccountUIExtension
import GLDatabase
import AppRepository

#if DEBUG
struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        GLPreviewController {
            SettingsViewController()
        }
    }
}
#endif

class SettingsViewController: BaseViewController, GLAPageProtocol, GLMPRouterDeepLinkDelegate {
    var pageName: String? = "settings"
    var pageParams: [String : Any]?
    
    var deeplink: DeepLink?
    
    let viewModel = SettingsViewModel()
    let actionModel = SettingsActionModel()
    
    required convenience init?(deeplink: DeepLink) {
        self.init(from: deeplink.from)
        self.deeplink = deeplink
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUI() {
        super.setUI()
        
    }
    
    override func setSwiftUIView() {
        super.setSwiftUIView()
        
        let swiftUIView = SettingsView(viewModel: viewModel, actionModel: actionModel)
        view.addSwiftUI(viewController: GLHostingController(rootView: swiftUIView)) { make in
            if self.isHiddenNavigationBar {
                make.edges.equalToSuperview()
            } else {
                make.top.equalTo(self.navigationView.snp.bottom)
                make.bottom.leading.trailing.equalToSuperview()
            }
        }
    }
    
    override func setActions() {
        super.setActions()
        actionModel.backAction.sink { [weak self] in
            guard let self = self else { return }
            self.popOrDismissController(defaultType: .pop, animated: true)
        }.store(in: &cancellables)
        
        actionModel.itemAction.sink { [weak self] model in
            guard let self = self else { return }
            self.onItemClick(model)
        }.store(in: &cancellables)
        
        actionModel.itemSwitchAction.sink { [weak self] model in
            guard let self = self else { return }
            self.onItemSwitchClick(model)
        }.store(in: &cancellables)
    
    }
}


//MARK: - Action

extension SettingsViewController {
    
    private func onItemClick(_ model: SettingsItemViewModel) {
        if let type = SettingItemType(rawValue: model.key) {
            switch type {
            case .premiumService:
                onPremiumServiceAction(model)
            case .restore:
                onRestoreAction()
            case .manageMembership:
                onMemberShipAction(model)
            case .setLanguage:
                onChangeLangauge(model)
            case .careNotification:
                onCareNotificationAction(model)
            case .allowToAccess:
                onAllowToAccessAction()
            case .clearCache:
                onClearCacheAction(model)
            case .encourageUs:
                onEncourageUsAction()
            case .help:
                onHelpAction()
            case .contactUs:
                onContactUsAction()
            case .snapTips:
                onSnapTipsAction()
            case .manageAccount:
                onManageAccountAction()
            case .login:
                onLoginAction()
            case .privacyPolicy:
                onPrivacyPolicyAction()
            case .termsOfUse:
                onTermsOfUseAction()
            case .appInfo:
                onAppInfoAction()
            case .rateApp:
                onRateAppAction()
            case .tellFriends:
                onTellFriendsAction()
            case .debugClearCache:
                onDebugClearCacheAction()
            case .debugDeleteDeviceId:
                onDebugDeleteDeviceId()
            case .debugVipPageTest:
                onDebugVipPageTest()
            case .deleteAccount:
                onDeleteAccountAction()
            default:
                break
            }
        }
    }
    
    private func onItemSwitchClick(_ model: SettingsItemViewModel) {
        if let type = SettingItemType(rawValue: model.key),
           type == .autoSavePhotos {
            onAutoSavePhotosToggle(model)
        }
    }
    
    // Premium Service
    private func onPremiumServiceAction(_ model: SettingsItemViewModel) {
        if IsVIP() {
            MemberShipManager.shared.openManageMemberShip()
        } else {
            MemberShipManager.shared.openPayment()
        }
    }
    
    // Manage MemberShip
    private func onMemberShipAction(_ model: SettingsItemViewModel) {
        MemberShipManager.shared.openManageMemberShip()
    }
    
    // Care Notification
    private func onCareNotificationAction(_ model: SettingsItemViewModel) {
        //        viewModel.notificationSheetPresent = true
    }
    
    
    //restore
    private func onRestoreAction() {
        GLToast.showLoading()
        Purchase.shared.restore { succeed in
            if succeed {
                GLMPAccount.restoreLogin(languageString: GLLanguage.currentLanguage.fullName, languageCode: GLLanguage.currentLanguage.languageId) { isSuccess, error in
                    GLToast.dismiss()
                }
            } else {
                GLToast.showError(GLMPLanguage.text_failed)
            }
        }
    }
    
    //切换语言
    private func onChangeLangauge(_ model: SettingsItemViewModel) {
        let style: UIAlertController.Style = IsIPad ? .alert : .actionSheet
        let vc = UIAlertController(title: nil, message: GLMPLanguage.text_set_language, preferredStyle: style)
        
        let languages = LanguageConfig.languages
        for (_, value) in languages.enumerated() {
            let mode = value
            let action = UIAlertAction.init(title: mode.displayName, style: .default) { action in
                let currentLanguage: String = GLLanguage.code() ?? "en"
                if currentLanguage != "languageCode" {
                    GLLanguage.updateCode(mode.code)
                    GLMPAccount.updateDeviceInfo(languageString: GLLanguage.currentLanguage.fullName)
                    
                    CommonAppLaunch.showMainViewController()
                    
                    NotificationCenter.default.post(name: NotificationKeys.LanguageChangedNotification, object: nil)
                }
            }
            vc.addAction(action)
        }
        
        let cancel = UIAlertAction.init(title: GLMPLanguage.text_cancel, style: .cancel) { _ in
            
        }
        vc.addAction(cancel)
        present(vc, animated: true)
    }
    
    // Allow to Access
    private func onAllowToAccessAction() {
        UIApplication.gl_openSettingURL()
    }
    
    
    //自动保存图片
    private func onAutoSavePhotosToggle(_ model: SettingsItemViewModel) {
        if case .toggle(let on) = model.style {
            let newValue = !on
            if newValue {
                GLMPPermission.requestSaveAblumPermission { granted in
                    if granted {
                        SettingsCache.enableAutoSaveToAlbums = newValue
                        model.style = .toggle(on: newValue)
                    }
                }
            } else {
                SettingsCache.enableAutoSaveToAlbums = newValue
                model.style = .toggle(on: newValue)
            }
        }
    }
    
    
    
    //清除缓存数据
    private func onClearCacheAction(_ model: SettingsItemViewModel) {
        GL().WebImage_ClearDiskCache {
            let sizeText = GLMPAppUtil.stringFromSize(0)
            model.style = .indicator(text: sizeText)
        }
    }
    
    
    // Encourage Us
    private func onEncourageUsAction() {
        UIApplication.gl_open(urlString: GLConfig.appStoreReviewLink)
    }
    
    //Help
    private func onHelpAction() {
        let helpViewController = SettingHelpViewController()
        self.navigationController?.pushViewController(helpViewController, animated: true)
    }
    
    
    //Contact Us
    private func onContactUsAction() {
        EmailSupportHelper.openSupportEmail()
    }
    
    //Snap Tips
    private func onSnapTipsAction() {
        //        self.navigationController?.pushViewController(SnapTipsInstructionsViewController(), animated: true)
    }
    
    //Login / SignUp
    private func onDeleteAccountAction() {
        if let vc = GL().AccountUI_DeleteAccountController(actionBlock: {[weak self] type, controller in
            guard let self = self else { return }
            switch type {
            case .loginOrSignUp: break
            case .knowledgeLevel: break
            case .deleteAccount:
                self.deleteAccount { [weak self] in
//                    guard let self = self else { return }
                    GLToast.dismiss()
//                    self.navigationController?.gl_pop(toController: SettingsViewController.self, animated: true)
                }
            case .unsubscribe:
                controller.navigationController?.popViewController(animated: true)
            case .refund:
                break
            }
        }) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // 账号删除完成后本地其他数据处理
    private func deleteAccount(_ completion: @escaping () -> Void) {
        UserCoreDataManager.shared.removeUserCoreData()
        GL().WebImage_ClearCache()
        GLMPAccount.setAccessToken(nil)
        
        GLMPAccount.userInitialise { _ in
            NotificationCenter.default.post(name: .init(rawValue: GLMediator.kUserDeleteNotification), object: nil)
            CommonAppLaunch.showMainViewController()
            completion()
        }
    }
    
    private func onLoginAction() {
        self.navigationController?.pushViewController(LoginViewController(from: self.pageName ?? ""), animated: true)
    }
    
    // Manage Account
    private func onManageAccountAction() {
        //        let controller = ManageAccountViewController(from: pageName)
        //        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //Privacy Policy
    private func onPrivacyPolicyAction() {
        GLMPAgreement.openPrivacyPolicy(with: self)
    }
    
    
    //Terms of Use
    private func onTermsOfUseAction() {
        GLMPAgreement.openTermsOfUse(with: self)
    }
    
    
    // App Info
    private func onAppInfoAction() {
        self.navigationController?.pushViewController(AppInfoViewController(), animated: true)
    }
    
    // Rate App
    private func onRateAppAction() {
        UIApplication.gl_open(urlString: GLConfig.appStoreReviewLink)
    }
    
    // Tell Friends
    private func onTellFriendsAction() {
        let title: String = GLMPLanguage.share_home_title_2
        let form = self.pageName ?? ""
        GL().Share_OpenSharePopView(includePlatforms: nil, title: title, from: form) {
            //埋点-取消
        } completeBlock: { [weak self] platform in
            guard let self = self else { return }
            GL().Share_Share(platform: platform,
                             title: nil,
                             content: nil,
                             url: GLConfig.appStoreLink,
                             image: UIImage(named: "pic_start_up"),
                             containerVC: self, from: form) { isComplete in
                //埋点-成功 or 失败
            }
        }
    }
    
    // MARK: - Debug
    
    private func onDebugClearCacheAction() {
        if GL().GLConfig_currentEnvironmentIsProduction() {
            return
        }
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        let fileManager = FileManager.default
        let paths = [NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0],
                     NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0],
                     NSTemporaryDirectory()]
        
        for path in paths {
            do {
                let items = try fileManager.contentsOfDirectory(atPath: path)
                for item in items {
                    let fullPath = (path as NSString).appendingPathComponent(item)
                    try fileManager.removeItem(atPath: fullPath)
                }
            } catch {
                print("Could not clear folder: \(error)")
            }
        }
        GLCache.removeAllObjects(sync: true)
    }
    
    private func onDebugDeleteDeviceId() {
        if GL().GLConfig_currentEnvironmentIsProduction() {
            return
        }
        
        // 翻译上面注释代码
        guard let userId = GL().Account_GetUserId() else {
            return
        }
        var title = "警告！！！"
        if userId.count > 0 {
            title = "\(title) UserId: \(userId)"
        }
        let alertController = UIAlertController(title: title, message: "此操作重启后会重新生成一个用户。非测试用户谨慎使用。此次操作会影响到你的线上用户。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in }
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
            self?.onDebugClearCacheAction()
            GL().Account_ResetDeviceId()
            // 删除 沙盒数据
            
            GLToast.show("Device Id删除成功！请退出App先")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func onDebugVipPageTest() {
        if GL().GLConfig_currentEnvironmentIsProduction() {
            return
        }
        
        /*
         UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"vip" message:@"" preferredStyle:UIAlertControllerStyleAlert];
         
         [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
         
         GLWeakifySelf;
         [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         GLStrongifySelf;
         NSString *text = alertVC.textFields.firstObject.text;
         if (![text containsString:@" "]) {
         if ([PurchaseUIGenerater containsWithMemo:text]) {
         [PurchaseUIGenerater.sharedInstance openWithController:self
         specifiedMemo:text
         extra:@{}
         enableInHistory:NO
         from:@"debug"];
         } else {
         [GLToast showError:@"找不到当前VipNumber"];
         }
         }
         }]];
         
         [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
         textField.placeholder = @"vip number";
         }];
         
         [self presentViewController:alertVC animated:YES completion:nil];
         */
        
        // 上面代码翻译
        let alertVC = UIAlertController(title: "vip", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            let text = alertVC.textFields?.first?.text ?? ""
            if !text.contains(" ") {
                let _ = GL().PurchaseUI_Open(text, historyVipMemo: nil, isVipInHistory: false, vc: self, type: .present,
                                             languageString: GLLanguage.currentLanguage.fullName,
                                             languageCode: GLLanguage.currentLanguage.languageId,
                                             from: "", identifyCount: 0, originGroup: nil, group: nil, abtestingID: nil, extra: [:]) { _, _ in
                    return ""
                }
            }
        }))
        alertVC.addTextField { textField in
            textField.placeholder = "vip number"
        }
        self.present(alertVC, animated: true, completion: nil)
    }
}

