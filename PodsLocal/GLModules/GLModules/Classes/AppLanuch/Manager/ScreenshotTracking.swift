//
//  ScreenshotTracking.swift
//  AINote
//
//  Created by user on 2024/4/24.
//

import Foundation
import GLLogging
import GLTrackingExtension
import GLMP

public protocol ScreenshotTrackingParamsProtocol: AnyObject {
    
    ///将截屏页面返回一个埋点参数, GLT_PARAM_ID, GLT_PARAM_TYPE, GLT_PARAM_FROM
    func getPageTrackingParams(_ vc: UIViewController) -> [String: Any]?
}


class ScreenshotTracking: NSObject {
    
    static let shared = ScreenshotTracking()
    
    private var observer: NSObjectProtocol?
    
    weak var delegate: ScreenshotTrackingParamsProtocol?
    
    private override init() {
        super.init()
        addObserver()
    }
    
    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observer = nil
    }
    
    
    
    private func addObserver() {
        self.observer = NotificationCenter.default.addObserver(forName:  UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.trackScreenshot()
            self?.uploadUserScreenshotIfNeed()
        })
    }
    
    private func trackScreenshot() {
        
        var params: [String: Any] = [:]
        
        let topVC = UIViewController.gl_top()
        params[GLT_PARAM_TARGET] = NSStringFromClass(topVC.classForCoder)
        
        if let parameters = delegate?.getPageTrackingParams(topVC) {
            params.gl_merge(parameters)
        }
        
        GLMPTracking.tracking("screenshot_click", parameters: params)
    }
    
    private func captureScreenshot(completion: ((Data?) -> Void)?) {
        DispatchQueue.main.async {
            var data: Data? = nil
            
            defer {
                completion?(data)
            }
            
            guard let keyWindow = UIApplication.shared.windows.first else {
                return
            }
            
            let layer = keyWindow.layer
            let format = UIGraphicsImageRendererFormat.default()
            let renderer = UIGraphicsImageRenderer(size: layer.frame.size, format: format)
            let screenshot = renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
           
            data = screenshot.jpegData(compressionQuality: 0.5)
        }
    }
    
    private func uploadUserScreenshotIfNeed() {
        if let val = GLMPABTesting.variableData(key: AppScreenshotAB.key), val == "1" {
            return
        }
        
        self.captureScreenshot { data in
            guard let data = data else {
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                
                GLMPUpload.upload(data: data, uploadType: .screenshot, fileType: .jpg, imageFrom: .album) { url, itemId, error in
                    if let error = error {
                        GLLogger.info("[screenshot] error = \(error.localizedDescription)")
                    } else {
                        GLLogger.info("[screenshot] fileUrl = \(url ?? "")")
                    }
                }
            }
        }
    }
}

fileprivate struct AppScreenshotAB {
    fileprivate static let key = "appconfig_uploadscreenshot_close"
}
