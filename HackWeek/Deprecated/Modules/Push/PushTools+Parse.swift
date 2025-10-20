//
//  PushTools+Parse.swift
//  DangJi
//
//  Created by Martin on 2022/3/31.
//  Copyright © 2022 Glority. All rights reserved.
//

import Foundation
import GLTrackingExtension
import GLCore
import UIKit
import GLConfig

extension PushTools {
    private var scheme: String {
        return GLConfig.appScheme
    }
    
    func parseDeeplink(_ deeplink: String, delegate: AppDelegate) {
        guard let url = URL(string: deeplink) else {
            return
        }
        
        //open external link
        if url.isExternalLink {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        if url.scheme != self.scheme {
            return
        }
        guard let host = url.host else {
            return
        }
        
        //参数
        let list: Array<URLQueryItem>? = URLComponents(string: deeplink)?.queryItems
        let queryDic = list?.parameters
//        LaunchVCLoader.shared.launch {[weak self] in
//            guard let self = self else {return}
//            switch host {
//            case "identify":
//                self.identify()
//            case "myplants":
//                self.gotoMyPlants()
//            case "home":
//                self.gotoHome()
//            case "diseasearticle":
//                self.jumpToDiseaseByQueryDic(queryDic)
//            case "plantdetail":
//                self.jumpToPlantByQueryDic(queryDic)
//            case "article":
//                self.jumpToArticleByQueryDic(queryDic)
//            case "consultationlist":
//                delegate.remoteChatNotification = true
//                PTChatBotManager.dealPushNotification(delegate: delegate)
//            default:
//                break
//            }
//        }
    }
}
//MARK: - 带参数的跳转类型
extension PushTools {
//    //诊断
//    private func jumpToDiseaseByQueryDic(_ dic: Dictionary<String, String>?) {
//        guard let dic = dic else {
//            return
//        }
//        guard let diseasesUid = dic["id"], diseasesUid.count > 0 else {
//            return
//        }
//        let vc = DiseaseDetailViewController(diseaseUid: diseasesUid)
//        self.tracking(type: "diseasearticle", jumpDesc: diseasesUid, contentDesc: dic.jsonString())
//        pushToVC(vc)
//    }
//    
//    //植物详情
//    private func jumpToPlantByQueryDic(_ dic: Dictionary<String, String>?) {
//        guard let dic = dic else {
//            return
//        }
//        guard let uid = dic["id"], uid.count > 0 else {
//            return
//        }
//        self.tracking(type: "plantdetail", jumpDesc: uid, contentDesc: dic.jsonString())
//        let vc = PlantDetailViewController.init(uId: uid, image: nil, mainImage: nil, from: .detail_Garden_Notification)
//        pushToVC(vc)
//    }
//    
//    //文章
//    private func jumpToArticleByQueryDic(_ dic: Dictionary<String, String>?) {
//        guard let dic = dic else {
//            return
//        }
//        guard let articleUrl = dic["url"], articleUrl.count > 0 else {
//            return
//        }
//        
//        self.tracking(type: "article", jumpDesc: articleUrl, contentDesc: dic.jsonString())
//        let vc = RecommendArticleDetailViewController.init(url: articleUrl, title: dic["title"])
//        pushToVC(vc)
//    }
  
}

//MARK: - 跳转到某个功能
extension PushTools {
//    private func identify() {
//        self.tracking(type: "identify")
//        FlowerImagePickerViewController.showNormalImagePicker()
//    }
//    
//    private func gotoMyPlants() {
//        self.tracking(type: "myplants")
//        YSTabBarController.ys_tabBarController?.jumpToRoot(type: .myplants)
//    }
//    
//    private func gotoHome() {
//        self.tracking(type: "home")
//        YSTabBarController.ys_tabBarController?.jumpToRoot(type: .home)
//    }
}

extension PushTools {
  
    ///tracking
//    func tracking(type: String, jumpDesc: String? = nil, contentDesc: String? = nil) {
//        var dic: Dictionary<String, Any> = [:]
//        dic[GLT_PARAM_TYPE] = type
//        dic[GLT_PARAM_STRING1] = jumpDesc
//        dic[GLT_PARAM_CONTENT] = contentDesc
//        if dic.count > 0 {
//            GL().Tracking_Event("push_notification_click", parameters: dic)
//        } else {
//            GL().Tracking_Event("push_notification_click")
//        }
//    }
//    
//    ///push跳转
//    func pushToVC(_ vc: UIViewController?) {
//        guard let vc = vc else {
//            return
//        }
//        let topVC = UIViewController.gl_top()
//        guard let navVC = topVC.navigationController else {
//            return
//        }
//        navVC.pushViewController(vc, animated: true)
//    }
}

extension URL {
    var isExternalLink: Bool {
        guard let scheme = self.scheme else {
            return false
        }
        if scheme == "https" || scheme == "http" {
            return true
        }
        return false
    }
}

fileprivate extension Array where Element == URLQueryItem {
    var parameters:[String: String] {
        let parameters:[String: String] = self.reduce(into: [:]) { partialResult, item in
            if let value = item.value {
                partialResult.updateValue(value, forKey: item.name)
            }
        }
        return parameters
    }
}
