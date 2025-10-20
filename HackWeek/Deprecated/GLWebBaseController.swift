//
//  GLWebBasedController.swift
//  EasySing
//
//  Created by stephenwzl on 2025/8/26.
//

import Foundation
import UIKit
import GLWidget
import GLAnalyticsUI
import WebKit

open class GLWebBasedController: GLBaseViewController {
    open var pageRoute: String {
        fatalError("need implementation")
    }
    
    open var debugEnabled: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    open var debugBaseURL: String {
        return "http://localhost:4567"
    }
    
    public var initialParams: [String: AnyHashable]?
    
    public convenience init(initialParams: [String : AnyHashable]? = nil, from: String? = nil) {
        self.init(from: from)
        self.initialParams = initialParams
    }
    
    public override init(from: String? = nil) {
        super.init(from: from)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var webview: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: configuration)
        // disable webview scroll bounce
        view.scrollView.bounces = false
        // transparent background
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        view.isOpaque = false
        return view
    }()
    
    private lazy var configuration: WKWebViewConfiguration = {
        var configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(GLAPISchemeHandler(), forURLScheme: "api")
        // add asset scheme handler
        configuration.setURLSchemeHandler(GLAssetSchemeHandler(), forURLScheme: "assets")
        return configuration
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webview)
        webview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
#if DEBUG
        if debugEnabled {
            if #available(iOS 16.4, *) {
                webview.isInspectable = true
            }
            // loadRequest from http://localhost:8080/{pageRoute}.html
            let url = URL(string: "\(debugBaseURL)/\(pageRoute)/index.html")!
            webview.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
            return
        }
#endif
        // webview load html from mainbundle/glbiz/{pageRoute}/index.html, allow baseURL to mainbundle/glbiz/{pageRoute}
        guard let htmlPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "glbiz/\(pageRoute)") else {
            assertionFailure("html not found: \(pageRoute)")
            return
        }
        let baseURL = Bundle.main.bundleURL.appendingPathComponent("glbiz")
        webview.loadFileURL(URL(fileURLWithPath: htmlPath), allowingReadAccessTo: baseURL)
    }
}


class GLAPISchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            sendErrorResponse(urlSchemeTask, error: "Invalid URL", code: -1)
            return
        }
        
        // 解析 API 名称，URL 格式为 api://api_name
        let apiName = url.host ?? url.pathComponents.last ?? ""
        guard !apiName.isEmpty else {
            sendErrorResponse(urlSchemeTask, error: "API name is required", code: -2)
            return
        }
        
        // 获取请求方法，只支持 POST
        let httpMethod = urlSchemeTask.request.httpMethod ?? "GET"
        guard httpMethod.uppercased() == "POST" else {
            sendErrorResponse(urlSchemeTask, error: "Only POST method is supported", code: -3)
            return
        }
        
        // 获取请求体数据
        let requestBody = urlSchemeTask.request.httpBody
        
        // 处理 API 调用
        handleAPICall(apiName: apiName, requestBody: requestBody, urlSchemeTask: urlSchemeTask)
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        // 取消正在进行的 API 调用
        // 这里可以根据需要实现取消逻辑
    }
    
    private func handleAPICall(apiName: String, requestBody: Data?, urlSchemeTask: WKURLSchemeTask) {
        // 解析请求参数
        var requestParams: [String: Any] = [:]
        if let body = requestBody {
            do {
                if let json = try JSONSerialization.jsonObject(with: body) as? [String: Any] {
                    requestParams = json
                }
            } catch {
                sendErrorResponse(urlSchemeTask, error: "Invalid JSON in request body", code: -4)
                return
            }
        }
        
        // 根据 API 名称分发处理
        let responseData: [String: Any]
        switch apiName {
            case "test":
                responseData = handleTestAPI(params: requestParams)
            case "user_info":
                responseData = handleUserInfoAPI(params: requestParams)
            case "app_config":
                responseData = handleAppConfigAPI(params: requestParams)
            case "pop":
                responseData = handlePopAPI(requestParams)
            case "dismiss":
                responseData = handleDismissAPI(requestParams)
            default:
                sendErrorResponse(urlSchemeTask, error: "Unknown API: \(apiName)", code: -5)
                return
        }
        
        // 发送 JSON 响应
        sendJSONResponse(urlSchemeTask, data: responseData)
    }
    
    // MARK: - API Handlers
    private func handlePopAPI(_ params: [String: Any]) -> [String: Any] {
        let animated = params["animated"] as? Bool ?? true
        DispatchQueue.main.async {
            Navigator.pop(animated)
        }
        return [
            "success": true,
            "message": "Pop API called successfully"
        ]
    }
    // handle dismiss
    private func handleDismissAPI(_ params: [String: Any]) -> [String: Any] {
        let animated = params["animated"] as? Bool ?? true
        DispatchQueue.main.async {
            Navigator.dismiss(animated)
        }
        return [
            "success": true,
            "message": "Dismiss API called successfully"
        ]
    }
    
    
    private func handleTestAPI(params: [String: Any]) -> [String: Any] {
        return [
            "success": true,
            "message": "Test API called successfully",
            "params": params,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
    
    private func handleUserInfoAPI(params: [String: Any]) -> [String: Any] {
        return [
            "success": true,
            "user": [
                "id": "12345",
                "name": "Test User",
                "email": "test@example.com"
            ]
        ]
    }
    
    private func handleAppConfigAPI(params: [String: Any]) -> [String: Any] {
        return [
            "success": true,
            "config": [
                "version": "1.0.0",
                "features": ["feature1", "feature2"],
                "settings": [
                    "debug": false,
                    "analytics": true
                ]
            ]
        ]
    }
    
    // MARK: - Response Helpers
    
    private func sendJSONResponse(_ urlSchemeTask: WKURLSchemeTask, data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let response = HTTPURLResponse(
                url: urlSchemeTask.request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": "application/json",
                    "Content-Length": "\(jsonData.count)"
                ]
            )!
            
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(jsonData)
            urlSchemeTask.didFinish()
        } catch {
            sendErrorResponse(urlSchemeTask, error: "Failed to serialize JSON response", code: -6)
        }
    }
    
    private func sendErrorResponse(_ urlSchemeTask: WKURLSchemeTask, error: String, code: Int) {
        let errorData: [String: Any] = [
            "success": false,
            "error": error,
            "code": code
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: errorData)
            
            let response = HTTPURLResponse(
                url: urlSchemeTask.request.url!,
                statusCode: 400,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": "application/json",
                    "Content-Length": "\(jsonData.count)"
                ]
            )!
            
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(jsonData)
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(NSError(domain: "GLAPISchemeHandler", code: code, userInfo: [NSLocalizedDescriptionKey: error]))
        }
    }
}

class GLAssetSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(NSError(domain: "GLAssetSchemeHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // 解析资源 ID，URL 格式为 assets://image_id
        let resourceId = url.host ?? url.pathComponents.last ?? ""
        
        // 使用 UIImage(named:) 加载图片
        guard let image = UIImage(named: resourceId) else {
            urlSchemeTask.didFailWithError(NSError(domain: "GLAssetSchemeHandler", code: -2, userInfo: [NSLocalizedDescriptionKey: "Resource not found: \(resourceId)"]))
            return
        }
        
        // 转换为 PNG 数据
        guard let imageData = image.pngData() else {
            urlSchemeTask.didFailWithError(NSError(domain: "GLAssetSchemeHandler", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG"]))
            return
        }
        
        // 创建响应，统一使用 PNG MIME type
        let response = URLResponse(
            url: url,
            mimeType: "image/png",
            expectedContentLength: imageData.count,
            textEncodingName: nil
        )
        
        // 返回响应和数据
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(imageData)
        urlSchemeTask.didFinish()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        // 这里不需要特殊处理
    }
}
