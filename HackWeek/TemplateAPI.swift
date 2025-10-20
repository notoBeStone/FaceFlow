//
//  TemplateAPI.swift
//  SupplementID
//
//  Created by stephenwzl on 2025/6/10.
//

import Foundation
import SwiftUI
import SwiftData
import StoreKit

/// 这里是模板工程暴露的基础可以调用的 API
/// UI 开发者无需关心具体实现，直接调用即可
/// 具体的函数签名由 API protocol 定义
struct TemplateAPI {
    /// 转化页相关API
    struct Conversion: ConversionAPI {}
    /// 视图栈相关API
    struct Navigator: NavigatorAPI {}
    /// ChatGPT相关API
    struct ChatGPT: ChatGPTAPI {}
    /// S3相关API
    struct S3: S3API {}
    /// 调试相关API
    struct Debugger: DebuggerAPI {}
    struct RemoteDB: RemoteDBAPI {}
}

struct TemplateConfig {
    /// 根视图, 这里决定了用户打开app后看到的第一个页面
    /// - Returns: 根视图
    static var rootView: AnyView {
        return AnyView(
            OnboardingRootView()
                .modelContainer(for: [WordBook.self, WordModel.self])
        )
    }
 /// 是否启动时展示转化页？（付费墙）
    /// Glority App通用逻辑，启动时每日最多展现2次。
    /// 如果因为 onboarding 未完成等条件导致不能展示，此处判断返回 false 即可
    static var showConversionAtLaunch: Bool {
        // 只有在 Onboarding 完成后才显示转化页
        // 直接从 UserDefaults 检查，避免线程安全问题
        return UserDefaults.standard.bool(forKey: "HackWords_OnboardingCompleted")
    }
    
    /// 转化页视图, 这里决定了用户点击转化页后看到的页面
    /// - Returns: 转化页视图
    static var conversionView: AnyView {
        AnyView(TrialableVipConversionPage())
    }

}

struct MediaQuery: MediaQueryAPI {}

struct ConversionSku {
    public enum SkuPeriod: Int {
        /// consumable sku returns none
        case none
        case weekly
        case monthly
        case yearly
        case seasonly
        case halfYearly
    }
    
    let skuId: String
    let trialDays: Int
    let period: SkuPeriod
    let product: SKProduct
}
// MARK: - API Definitions

/// 付费转化相关API协议
protocol ConversionAPI {
    /// 转化页中，用于设定当前页面上可供购买的 sku，不设定会导致无法购买
    @MainActor
    static func enableCurrentSkus(_ skus: [String])
    /// 获取 sku信息, 用来展示到转化页上
    /// - Parameters:
    ///   - skuId: sku ID
    /// - Returns: sku 信息
    /// - Example: TemplateAPI.Conversion.fetchSkuInfo("premium_yearly")
    static func fetchSkuInfo(_ skuId: String) -> ConversionSku?
    /// 显示付费墙
    /// - Parameters:
    ///   - from: 来源
    ///   - animationType: 动画类型, 默认是present, addChild 是添加到当前视图控制器
    /// - Example: TemplateAPI.Conversion.showVip()
    @MainActor
    static func showVip(from: String, animationType: PaywallNotifier.ShowVipAnimationType)
    
    /// 关闭付费墙页面
    /// - Example: TemplateAPI.Conversion.closePage()
    @MainActor
    static func closePage()
    
    /// 开始购买流程
    /// - Parameters:
    ///   - skuId: 商品ID
    ///   - trialable: 是否支持试用
    /// - Example: TemplateAPI.Conversion.startPurchase("premium_yearly", trialable: true)
    @MainActor
    static func startPurchase(_ skuId: String, trialable: Bool)
    
    /// 查看使用条款
    /// - Example: TemplateAPI.Conversion.showTermsOfUse()
    @MainActor
    static func showTermsOfUse()
    
    /// 查看隐私政策
    /// - Example: TemplateAPI.Conversion.showPrivacyPolicy()
    @MainActor
    static func showPrivacyPolicy()
    
    @MainActor
    static func showSubscriptionTerms()
    
    /// 查看订阅管理
    /// - Example: TemplateAPI.Conversion.manageSubscription()
    @MainActor
    static func manageSubscription()
    
    /// 恢复购买
    /// - Example: TemplateAPI.Conversion.restorePurchase()
    @MainActor
    static func restorePurchase()
    
    
    @MainActor
    static var trialReminderEnabled: Bool { get set }
    
    @MainActor
    static func changeReminder(to enabled: Bool, completion: @escaping (_ granted: Bool) -> Void)
}

/// 导航相关API协议
protocol NavigatorAPI {
    /// 推入新的SwiftUI视图到导航栈
    /// - Parameters:
    ///   - view: 要推入的SwiftUI视图
    ///   - from: 来源标识，用于追踪导航源头, 默认是 nil
    ///   - animated: 是否开启动画, 默认是 true
    /// - Example: TemplateAPI.Navigator.push(DetailView(), from: "home")
    static func push<Content: View>(_ view: Content, from: String?, animated: Bool)
    
    /// 模态展示SwiftUI视图
    /// - Parameters:
    ///   - view: 要展示的SwiftUI视图
    ///   - from: 来源标识，用于追踪导航源头, 默认是 nil
    ///   - animated: 是否开启动画, 默认是 true
    /// - Example: TemplateAPI.Navigator.present(SettingsView(), from: "main")
    static func present<Content: View>(_ view: Content, from: String?, animated: Bool)
    
    /// 模态展示UIViewController
    /// - Parameters:
    ///   - vc: 要展示的视图控制器
    ///   - animated: 是否使用动画，默认为true
    ///   - completion: 展示完成后的回调闭包, 默认是 nil
    /// - Example: TemplateAPI.Navigator.present(imagePickerController, animated: true)
    static func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    /// 替换当前视图为新的SwiftUI视图
    /// - Parameters:
    ///   - view: 要替换成的SwiftUI视图
    ///   - from: 来源标识，用于追踪导航源头, 默认是 nil
    ///   - animated: 是否开启动画, 默认是 true
    /// - Example: TemplateAPI.Navigator.pushReplace(LoginView(), from: "onboarding")
    static func pushReplace<Content: View>(_ view: Content, from: String?, animated: Bool)
    
    /// 返回到上一级视图
    /// - Parameters:
    ///   - animated: 是否使用动画，默认为true
    /// - Example: TemplateAPI.Navigator.pop()
    static func pop(_ animated: Bool)
    
    /// 返回到根视图，清空整个导航栈
    /// - Parameters:
    ///   - animated: 是否使用动画，默认为true
    /// - Example: TemplateAPI.Navigator.popAll()
    static func popAll(_ animated: Bool)
    
    /// 关闭模态展示的视图
    /// - Parameters:
    ///   - animated: 是否使用动画，默认为true
    ///   - completion: 关闭完成后的回调闭包, 默认是 nil
    /// - Example: TemplateAPI.Navigator.dismiss()
    static func dismiss(_ animated: Bool, completion: (() -> Void)?)
    
    /// 重置当前导航栈为指定视图
    /// - Parameters:
    ///   - view: 要重置的SwiftUI视图
    /// - Example: TemplateAPI.Navigator.reset(HomeView())
    static func reset<Content: View>(_ view: Content)
    
    /// 打开预设的 Settings 界面
    static func openSettings(_ from: String)
}

/// 配置相关API协议
protocol TemplateConfigProtocol {
    
    static var showConversionAtLaunch: Bool { get }
    
    /// 根视图, 这里决定了用户打开app后看到的第一个页面
    /// - Returns: 根视图
    static var rootView: AnyView { get }
    
    /// 付费墙视图, 这里决定了用户点击付费墙后看到的页面
    /// - Returns: 付费墙视图
    static var conversionView: AnyView { get }
}

/// 媒体查询相关API协议
protocol MediaQueryAPI {
    /// 安全区域
    /// 用于计算视图和安全区域的间距，如导航栏高度，底部安全区域高度等
    static var safeArea: EdgeInsets { get }
    
    /// 是否是iPad
    static var isIPad: Bool { get }
    
    /// 屏幕尺寸
    /// 用于计算视图的尺寸，如屏幕宽度，屏幕高度等
    static var screenSize: (width: CGFloat, height: CGFloat) { get }
}

protocol DebuggerAPI {
    /// 显示一个全屏的调试信息，仅在开发环境有效
    /// - Parameters:
    ///   - message: 调试信息，会用红底白字显示，可关闭
    /// - Example: TemplateAPI.Debugger.showDebugMessage("This is a debug message")
    static func showDebugMessage(_ message: String)
}

enum S3ErrorType: Error {
    case invalidUploadType
    case invalidData
    case unknownError
}

protocol S3API {
    /// 上传文件到S3
    /// - Parameters:
    ///   - data: 文件数据
    ///   - fileExtension: 文件扩展名
    /// - Returns: 文件URL
    /// - Throws: S3ErrorType
    static func upload(data: Data, fileExtension: String) async throws ->  String
}

struct RemoteDBObject {
    let id: Int64
    let object: String
    let createAt: Date
    let updateAt: Date
    let schema: String
}

struct RemoteDBListObjectsResponse {
    let schema: String
    let objects: [RemoteDBObject]
    let total: Int
}

enum RemoteDBError: Error {
    case operationFailed(String)
    case notFound
    case unknownError
    case invalidRequest
}

protocol RemoteDBAPI {
    /// 存储对象数据到远程数据库, 此操作将新建一条记录
    /// - Parameters:
    ///   - data: 对象数据, 一般情况下是json字符串
    ///   - schema: 对象所属的schema，用于区分不同类型的对象
    /// - Returns: 存储后的对象
    /// - Throws: RemoteDBError
    static func storageObject(_ data: String, schema: String) async throws -> RemoteDBObject
    /// 获取对象列表，此操作将返回一个对象列表，并返回总记录数
    /// - Parameters:
    ///   - schema: 对象所属的schema，用于区分不同类型的对象
    ///   - lastId: 上一次获取的最后一条记录的id，用于分页
    ///   - pageSize: 每页获取的记录数，默认是 100
    /// - Returns: 对象列表
    /// - Throws: RemoteDBError
    static func listObjects(_ schema: String, lastId: Int64?, pageSize: Int) async throws -> RemoteDBListObjectsResponse
    /// 更新对象数据，此操作将更新一条记录，无需指定 schema
    /// - Parameters:
    ///   - data: 对象数据, 一般情况下是json字符串
    ///   - id: 对象id
    /// - Throws: RemoteDBError
    static func updateObject(_ data: String, id: Int64) async throws
    /// 获取对象数据，此操作将返回一个对象
    /// - Parameters:
    ///   - id: 对象id
    /// - Returns: 对象
    /// - Throws: RemoteDBError
    static func getObject(_ id: Int64) async throws -> RemoteDBObject
    /// 删除对象数据，此操作将删除一条记录
    /// - Parameters:
    ///   - id: 对象id
    /// - Returns: 对象
    /// - Throws: RemoteDBError
    static func deleteObject(_ id: Int64) async throws
}
