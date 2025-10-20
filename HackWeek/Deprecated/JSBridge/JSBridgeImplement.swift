//
//  JSBridgeImplement.swift
//  AINote
//
//  Created by user on 2024/5/16.
//

import Foundation
import GLWebView
import GLResource
import GLWidget
import GLTrackingExtension
import GLMP
import GLComponentAPI
import AppModels
import GLFeedbackExtension
import GLCore

enum RootJSBMethod: String, CaseIterable {
    typealias RawValue = String
    
    case apiAvailable               = "apiAvailable"
//    case clickLikeBtn               = "clickLikeBtn"
//    case contentFeedback            = "contentFeedback"
//    // 发AB埋点
//    case getABTest                  = "getABTestingModel"
//    // 不发AB埋点
//    case getABTestNoTracking        = "getABTestingModelNoTracking"
//    case jumpChooseCity             = "jumpChooseCity"
//    case jumpWateringCalculator     = "jumpWateringCalculator"
//    case jumpImages                 = "jumpImages"
//    case reportEvent                = "reportEvent"
//
//    case trackABTestingMoreData     = "trackABTestingMoreData"  // AB测试埋点
//    
//    // V3.80 5.0 结果页新增jsb
//    case checkHealthStatus          = "checkHealthStatus"       // 健康卡片点击
//    case jumpExpertSupport          = "jumpExpertSupport"       // 跳转到专家咨询
//    case jumpToRepottingChecker     = "jumpToRepottingChecker"  // 跳转到换盆检测
//    
//    case resultV5OpenLightMeter     = "resultV5OpenLightMeter"  // 5.0结果页 打开光度计
//    case resultV5ShowSummary        = "resultV5ShowSummary"  // 5.0结果页 点击 BasicInfo 叹号
//    case resultV5ClickDiseaseItem     = "resultV5ClickDiseaseItem" // 5.0结果页 点击物种病症
//    case resultV5ClickPopularQuestion = "resultV5ClickPopularQuestion" // 5.0结果页 点击Popular Question
//    case resultV5ClickCareNeeds = "resultV5ClickCareNeeds" // 5.0结果页点击CareNeeds 进入养护细分场景
//    case resultV5ClickFunFact = "resultv5ClickFunFact" // 5.0结果页点击fun fact
//    case resultV5ClickToxic = "resultV5ClickToxic"  // 5.0结果页点击toxic
//    case resultV5ClickWeed = "resultV5ClickWeed"  // 5.0结果页点击weed
//    case resultV5ClickReminder = "resultV5ClickReminder" // 5.0结果页点击添加 reminder
//    case resultV5ClickShare = "resultV5ClickShare" // 5.0结果页点击share
//    case resultV5jumpWateringCalculator = "resultV5jumpWateringCalculator" // 5.0 结果页点击 水量计算器
//    case resultV5UpdateReminder = "resultV5UpdateReminder" // 5.0 结果页点击 更新 reminder
//    case resultV5jumpDistributionMapDetail = "resultV5jumpDistributionMapDetail" // 5.0 结果页点击 跳转到 distribution map详情
//    case resultV5jumpHealthCardImage = "resultV5jumpHealthCardImage" // 5.0 结果页点击 健康卡片图片查看 图片
//    //重构新增
//    case jumpToPlant                 = "jumpToPlant"   //跳转到植物详情页， 通过uid
//    case jumpToWeb                   = "jumpToWeb"     //跳转到web页面
}

class RootJSBridgeImplement: JSBImplement {
    static let badParamsMessageDesc = "bad params"
    static let notFoundTarget = "not found target"
    
    
    override class var scope: String { ParamKeys.root }

    override func onInvocation(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
        guard let method = invocation.invoke.method else {
            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: "method missing"))
            return
        }
        
        guard let methodEnum = RootJSBMethod(rawValue: method) else {
            completion?(FailedWebviewResponse(errorCode: .noSuchMethod, errorMessage: "no such method"))
            return
        }
        
//        switch methodEnum {
//            // Common
//        case .apiAvailable: handleApiAvailable(invocation, completion: completion)
//        case .getABTest: handleGetABTesing(invocation, completion: completion)
//        case .reportEvent: handleReportEvent(invocation, completion: completion)
//        case .contentFeedback: handleContentFeedback(invocation, completion: completion)
//        case .resultV5ClickCareNeeds: handlerResultV5ClickCareNeeds(invocation, completion: completion)
//        case .resultV5ShowSummary: handlerResultV5ShowSummary(invocation, completion: completion)
//        case .resultV5jumpDistributionMapDetail: handlerResultV5jumpDistributionMapDetail(invocation, completion: completion)
//        case .jumpImages: handleJumpImages(invocation, completion: completion)
//        case .resultV5ClickPopularQuestion: handlerResultV5ClickPopularQuestion(invocation, completion: completion)
//        case .clickLikeBtn: handleLikebtn(invocation, completion: completion)
//        case .trackABTestingMoreData: handleTrackABTestingMoreData(invocation, completion: completion)
//        case .getABTestNoTracking: handleGetABTestingNoTrack(invocation, completion: completion)
//        case .resultV5ClickFunFact: handlerResultV5ClickFunFact(invocation, completion: completion)
//        case .resultV5ClickToxic: handlerResultV5ClickToxic(invocation, completion: completion)
//        case .resultV5ClickWeed: handlerResultV5ClickWeed(invocation, completion: completion)
//        case .jumpChooseCity: handlejumpChooseCity(invocation, completion: completion)
//        case .resultV5ClickDiseaseItem: handlerResultV5ClickDiseaseItem(invocation, completion: completion)
//        case .jumpToPlant: handleJumpToPlant(invocation, completion: completion)
//        case .jumpToWeb: handleJumpToWeb(invocation, completion: completion)
//        case .resultV5ClickShare: handlerResultV5ClickShare(invocation, completion: completion)
//
//            // Business
//        case .resultV5ClickReminder: handlerResultV5ClickReminder(invocation, completion: completion)
//        case .resultV5UpdateReminder: handlerResultV5UpdateReminder(invocation, completion: completion)
//        case .jumpWateringCalculator, .resultV5jumpWateringCalculator: handlejumpWateringCalculator(invocation, completion: completion)
//        case .jumpToRepottingChecker: handlerJumpToRepottingChecker(invocation, completion: completion)
//        case .resultV5jumpHealthCardImage: handlerResultV5JumpHealthCardImage(invocation, completion: completion)
//        case .checkHealthStatus: handlerCheckHealthStatus(invocation, completion: completion)
//        case .resultV5OpenLightMeter: handlerResultV5OpenLightMeter(invocation, completion: completion)
//        case .jumpExpertSupport: handlerJumpExpertSupport(invocation, completion: completion)
//
//
//        }
    }
}

extension RootJSBridgeImplement {
    
//    func handleApiAvailable(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let methodName: String = invocation.getParam(ParamKeys.methodName) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: "missing methodName"))
//            return
//        }
//        let available = RootJSBMethod.allCases.map({ $0.rawValue }).contains(methodName)
//        completion?(SuccessWebviewResponse(responseBody: [ParamKeys.available: AnyCodable(available)]))
//    }
//    
//    func handleGetABTesing(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        _handleGetABTesing(invocation, completion: completion)
//    }
//    
//    func handleGetABTestingNoTrack(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        _handleGetABTesing(invocation, completion: completion, activate: false)
//    }
//    
//    private func _handleGetABTesing(_ invocation: JSBInvocation, completion: JSBInvocationCallback?, activate: Bool = true) {
//        guard let key: String = invocation.getParam(ParamKeys.key) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: "missing key"))
//            return
//        }
//        let model = GLMPABTesting.variableModel(key: key, activate: activate)
//        completion?(SuccessWebviewResponse(responseBody: [
//            ParamKeys.value: AnyCodable(model?.variable ?? ""),
//            ParamKeys.variableData: AnyCodable(model?.variableData ?? "")
//        ]))
//    }
//    
//    /**
//     {
//         "methodName": "trackABTestingMoreData",
//         "params": {
//            key: "onetime_resultquickfacts_ab",
//            dataKey: "on_click",
//            dataValue: "110528"
//         }
//     }
//     */
//    func handleTrackABTestingMoreData(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let key: String = invocation.getParam(ParamKeys.key),
//              let dataKey: String = invocation.getParam(ParamKeys.dataKey),
//              let dataValue: String = invocation.getParam(ParamKeys.dataValue) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams,
//                                              errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        GLMPABTesting.trackMoreData(key: key, dataKey: dataKey, dataValue: dataValue)
//        completion?(SuccessWebviewResponse())
//    }
//    
//    
//    func handleReportEvent(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let eventName: String = invocation.getParam(ParamKeys.eventName) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: "missing eventName"))
//            return
//        }
//        
//        var params: [String: Any]? = invocation.getParam(ParamKeys.params)
//        
//        // update `index` value type
//        if let index = params?[ParamKeys.index] as? Int {
//            params?[ParamKeys.index] = "\(index)"
//        }
//        
//        if let key = params?[ParamKeys.key] as? Int {
//            params?[ParamKeys.key] = "\(key)"
//        }
//        GLMPTracking.tracking(eventName, parameters: params)
//        completion?(SuccessWebviewResponse())
//    }
//    
//  
//    func handleJumpImages(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        var index: Int = -1
//        
//        if let idx: Int = invocation.getParam(ParamKeys.index) {
//            index = idx
//        }
//        
//        if let idx: String = invocation.getParam(ParamKeys.index) {
//            index = Int(idx) ?? -1
//        }
//        
//        guard index != -1, let images: [[String: Any]] = invocation.getParam(ParamKeys.images)  else {
//            completion?(FailedWebviewResponse(errorCode: .badParams,
//                                              errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        var imageUrls: [String] = []
//        images.forEach {
//            if let url = $0[ParamKeys.url] as? String {
//                imageUrls.append(url)
//            }
//        }
//        
//        if index > images.count {
//            completion?(FailedWebviewResponse(errorCode: .badParams,
//                                              errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        let fromPage = invocation.webview?.dataSource?.getPayload()?[WebViewParamKeys.fromPage.rawValue] as? String
//        
//        PhotoBrowser.showImageUrls(imageUrls, index: index, fromPage: fromPage ?? "")
//        
//        completion?(SuccessWebviewResponse())
//    }
//    
//    /// ... feedback
//    func handleContentFeedback(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//
//        guard let uid = (invocation.invoke.params?[ParamKeys.uid]?.value as? String),
//              let layoutName = (invocation.invoke.params?[ParamKeys.layoutName]?.value as? String) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams,
//                                              errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        let itemId = (invocation.invoke.params?[ParamKeys.itemId]?.value as? String) ?? "-1"
//        
//        let pageSource = (invocation.invoke.params?[ParamKeys.pageSource]?.value as? String) ?? ParamKeys.jsb
//        
//        IdentifyFeedback.openResultFeedback(itemId: Int64(itemId) ?? 0,
//                                            uid: uid,
//                                            from: pageSource,
//                                            layoutName: layoutName)
//        
//        completion?(SuccessWebviewResponse())
//    }
//    
//    /// 细分场景
//    func handlerResultV5ClickCareNeeds(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let payload = invocation.webview?.dataSource?.getPayload() else {
//            return
//        }
//        guard let cmsName = payload[WebViewParamKeys.cmsName.rawValue] as? CmsNameModel else {
//            return
//        }
//        let params = invocation.invoke.params
//
//        guard let type = params?[ParamKeys.type]?.value as? String,
//              let from = params?[ParamKeys.from]?.value as? String else {
//            return
//        }
//        let plantName = cmsName.name.preferredName
//        
//        var topicGroupType: TopicGroupType?
//
//        switch type {
//        case "water":
//            topicGroupType = .water
//        case "soil":
//            topicGroupType = .soil
//        case "fertilizer":
//            topicGroupType = .fertilizer
//        case "sun":
//            topicGroupType = .sunlight
//        case "temperature":
//            topicGroupType = .temperature
//        case "repotting":
//            topicGroupType = .pot
//        case "pruning":
//            topicGroupType = .pruning
//        case "propagation":
//            topicGroupType = .propagation
//        default:
//            topicGroupType = nil
//        }
//
//        let uid = cmsName.uid
//        var itemIdStr: String = ""
//        if let itemId = params?[ParamKeys.itemId]?.value as? String {
//            itemIdStr = itemId
//        }
//
//        let enableArray:[TopicGroupType] = [.water, .sunlight, .temperature, .propagation, .pruning, .fertilizer, .soil, .pot]
//
//        if let topicGroupType = topicGroupType, enableArray.contains(topicGroupType) {
//            let startParams = PlantCareDataManager.getPlantCareStartupParams(from: from,
//                                                                             itemId: itemIdStr,
//                                                                             careResult: payload[WebViewParamKeys.careResult.rawValue] as? CareResultModel,
//                                                                             tagEngine: payload[WebViewParamKeys.tagEngineResult.rawValue] as? TagEngineResultModel,
//                                                                             topicType: topicGroupType)
//            GLMPRouter.open(DeepLinks.commonCmsStaticWebViewDeepLink(from: from, pageName: nil, title: plantName, contentType: "care_scenes", uid: uid, startParams: startParams))
//            completion?(SuccessWebviewResponse())
//        } else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//        }
//    }
//    
//    func handlerResultV5jumpDistributionMapDetail(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let sourceUrls: [String] = invocation.getParam(ParamKeys.sourceUrls),
//              let index: Int = invocation.getParam(ParamKeys.index),
//              let payload = invocation.webview?.dataSource?.getPayload(),
//              let cmsName = payload[WebViewParamKeys.cmsName.rawValue] as? CmsNameModel else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        let vc = PlantDistrutionMapViewController(index: index, sourceUrls: sourceUrls, habitat: cmsName.habitat)
//        UIViewController.gl_top().navigationController?.pushViewController(vc, animated: true)
//        completion?(SuccessWebviewResponse())
//    }
//    
//    func handlerResultV5ClickPopularQuestion(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        let params = invocation.invoke.params
//        guard let urlString = params?[ParamKeys.url]?.value as? String,
//              let from = params?[ParamKeys.from]?.value as? String,
//        let startUpParams: [String: Any] = params?[ParamKeys.startupParams]?.value as? [String: Any] else {
//            completion?(FailedWebviewResponse(errorCode: .badParams,
//                                              errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        GLMPRouter.open(DeepLinks.commonCmsStaticWebViewDeepLink(from: from,
//                                                                 pageName: ParamKeys.popularQuestions,
//                                                                 title: GLMPLanguage.AINote_resultpage_popular_questions_title,
//                                                                 contentType: "",
//                                                                 uid: nil,
//                                                                 url: urlString,
//                                                                 startParams: startUpParams))
//        
//        completion?(SuccessWebviewResponse())
//    }
//    
//    func handlerResultV5ClickDiseaseItem(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//
//        let from = invocation.getParam(ParamKeys.from) ?? invocation.webview?.dataSource?.getPayload()?[WebViewParamKeys.fromPage.rawValue] as? String
//        guard let diseaseId: String = invocation.getParam(ParamKeys.uid),
//              let imageUrl: String = invocation.getParam(ParamKeys.imageUrl) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams,
//                                              errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        GLMPRouter.open(DeepLinks.commonProblemsDetailDeepLink(from: from ?? "", uid: diseaseId, imageUrl: imageUrl))
//    }
//    
//    func handleLikebtn(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let type = invocation.invoke.params?[ParamKeys.type]?.value as? String else {
//            return
//        }
//        
//        let isLike = (type == ParamKeys.like)
//        var params: [String: Any] = [:]
//        if let uid: String = invocation.getParam(ParamKeys.uid),
//           let itemId: String = invocation.getParam(ParamKeys.itemId),
//            let from: String = invocation.getParam(ParamKeys.pageSource) {
//            params[GLT_PARAM_TYPE] = uid
//            params[GLT_PARAM_ID] = itemId
//            params[GLT_PARAM_FROM] = from
//        }
//    
//        let layoutName: String? = invocation.getParam(ParamKeys.layoutName)
//        
//        if isLike {
//            GLToast.showTitle(GLMPLanguage.feed_hud_report)
//            GL().Feedback_TrackLike(type: .recognizedDislike, parameters: params)
//        } else {
//            IdentifyFeedback.openResultDislikeFeedback(layoutName: layoutName ?? "", parameters: params)
//        }
//        completion?(SuccessWebviewResponse())
//    }
//    
//    func handlejumpChooseCity(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        
//        let from: String = invocation.invoke.params?[ParamKeys.from]?.value as? String ?? ""
//        GLMPRouter.open(DeepLinks.chooseALocationDeeplink(from: from))
//    }
// 
//    func handlerResultV5ShowSummary(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let title: String = invocation.getParam(ParamKeys.title),
//              let summary: String = invocation.getParam(ParamKeys.summary) else {
//            return
//        }
//        
//        let viewController: SummaryModalViewController = .init(titleText: title, summary: summary)
//        let targetController = UIViewController.gl_top()
//        targetController.present(viewController, animated: true)
//        completion?(SuccessWebviewResponse())
//    }
//    
//    
//    func handlerResultV5ClickFunFact(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let contentType: String = invocation.getParam(ParamKeys.contentType) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        
//        guard let payload = invocation.webview?.dataSource?.getPayload() else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        guard let cmsName = payload[WebViewParamKeys.cmsName.rawValue] as? CmsNameModel else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//
//        let from: String = invocation.invoke.params?[ParamKeys.from]?.value as? String ?? ""
//        let uid = (invocation.invoke.params?[ParamKeys.uid]?.value as? String) ?? ""
//        var startupParams: [String: Any] = invocation.getParam(ParamKeys.startupParams) ?? [:]
//        startupParams[ParamKeys.subPage] = true
//
//        GLMPRouter.open(DeepLinks.commonCmsStaticWebViewDeepLink(from: from, pageName: nil, title: cmsName.name.preferredName, contentType: contentType, uid: uid, startParams: startupParams))
//        completion?(SuccessWebviewResponse())
//    }
//    
//    func handlerResultV5ClickToxic(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let payload = invocation.webview?.dataSource?.getPayload(),
//              let cmsName = payload[WebViewParamKeys.cmsName.rawValue] as? CmsNameModel else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//
//        let uid: String = cmsName.uid
//        let title: String = cmsName.name.preferredName
//        let from: String = invocation.getParam(ParamKeys.from) ?? "identifyResult"
//        let fromPet: Bool = invocation.getParam(ParamKeys.fromPet) ?? false
//        var startupParams: [String: Any] = invocation.getParam(ParamKeys.startupParams) ?? [:]
//        startupParams[ParamKeys.subPage] = true
//        startupParams[ParamKeys.fromPet] = fromPet
//
//        GLMPRouter.open(DeepLinks.commonCmsStaticWebViewDeepLink(from: from, pageName: nil, title: title, contentType: ParamKeys.cmsStaticUrlContentTypeToxic, uid: uid, startParams: startupParams))
//        completion?(SuccessWebviewResponse())
//    }
//    
//    func handlerResultV5ClickWeed(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let payload = invocation.webview?.dataSource?.getPayload(),
//              let cmsName = payload[WebViewParamKeys.cmsName.rawValue] as? CmsNameModel else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//
//        let uid: String = cmsName.uid
//        let title: String = cmsName.name.preferredName
//        let from: String = invocation.getParam(ParamKeys.from) ?? "identifyResult"
//        var startupParams: [String: Any] = invocation.getParam(ParamKeys.startupParams) ?? [:]
//        startupParams[ParamKeys.subPage] = true
//        startupParams[ParamKeys.isWeed] = true
//        startupParams[ParamKeys.isInvasiveCur] = cmsName.isInvasive
//        startupParams[ParamKeys.otherInvasiveCountries] = cmsName.invasiveOtherCountry
//        startupParams[ParamKeys.imageUrls] = cmsName.matchedSimilarImages.compactMap({ $0.imageUrl })
//        var itemId: String = ""
//        if let itemIdInt = payload[WebViewParamKeys.itemId.rawValue] as? Int64 {
//            itemId = String(itemIdInt)
//        }
//        startupParams[ParamKeys.itemId] = itemId
//
//        if let countryName = Locale.current.localizedString(forRegionCode: GLMPAppUtil.countryCode) {
//            startupParams[ParamKeys.countryName] = countryName
//        }
//
//        let engineResult = payload[WebViewParamKeys.tagEngineResult.rawValue] as? TagEngineResultModel
//        
//        let careResult = payload[WebViewParamKeys.careResult.rawValue] as? CareResultModel
//        
//        let startParams = PlantCareDataManager.getPlantCareStartupParams(from: from, itemId: itemId, careResult: careResult, tagEngine: engineResult, topicType: .soil)
//        startupParams.gl_merge(startParams)
//
//        GLMPRouter.open(DeepLinks.commonCmsStaticWebViewDeepLink(from: from, pageName: nil, title: title, contentType: ParamKeys.cmsStaticUrlContentTypeWeed, uid: uid, startParams: startupParams))
//        completion?(SuccessWebviewResponse())
//        
//    }
//    
//    
//    func handlerResultV5ClickShare(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
////        guard let source = invocation.webview?.payload?["data"] as? ResultDetailWebViewDataSource else {
////            return
////        }
////        guard let index = invocation.invoke.params?[ParamKeys.index]?.value as? Int else {
////            return
////        }
////        guard let cmsName = source.plant.cmsName, let careResult = source.careResult else {
////            return
////        }
////        if let captureImage = source.captureResult?.imageModels.first?.image {
////            IdentifyResultShareView.show(cmsName: cmsName,
////                                         careResult: careResult,
////                                         captureImage: captureImage,
////                                         index: index,
////                                         owner: UIViewController.gl_top())
////        } else if let mainImageUrl = cmsName.mainImage?.imageUrl {
////            GLToast.showLoading()
////            GL().WebImage_DownloadImage(from: mainImageUrl, priority: .high) { image, error, urlString in
////                GLToast.dismiss()
////                if let image = image {
////                    IdentifyResultShareView.show(cmsName: cmsName,
////                                                 careResult: careResult,
////                                                 captureImage: image,
////                                                 index: index,
////                                                 owner: UIViewController.gl_top())
////                }
////            }
////        }
//        
//    }
//    
//    func handleJumpToPlant(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        //todo, 植物的物种详情页
//        debugPrint("jumpToPlant be called")
//    }
//    
//    func handleJumpToWeb(_ invocation: JSBInvocation, completion: JSBInvocationCallback?) {
//        guard let url: String = invocation.getParam(ParamKeys.url) else {
//            completion?(FailedWebviewResponse(errorCode: .badParams, errorMessage: Self.badParamsMessageDesc))
//            return
//        }
//        let from: String = invocation.invoke.params?[ParamKeys.from]?.value as? String ?? ""
//        let startupParams: [String: Any]? = (invocation.invoke.params?[ParamKeys.startupParams]?.value as? [String: Any])
//        
//        GLMPRouter.open(DeepLinks.commonBottomSheetDialogWebViewDeepLink(from: from, pageName: nil, title: nil, url: url, startParams: startupParams))
//        
//        completion?(SuccessWebviewResponse())
//    }
}
