//
//  NetworkManager.swift
//  AINote
//
//  Created by xie.longyan on 2023/2/16.
//

import Foundation
import GLNetworkingMessage
import DGMessageAPI
import GLCore
import GLConfig_Extension
import GLBaseApi

public class GLMPNetwork {
    
    private static var manager: GLMessageAPINetworkingManager? = requestManager()
    
    public static var requestAdditionalHeaderHandler: ((any APIEncodableRequest) -> [String: String]?)?
    
    private static func requestManager() -> GLMessageAPINetworkingManager? {
        let host = GL().GLConfig_getServerAddress()
        guard let url = URL(string: host) else {
            return nil
        }
        let manager = GLMessageAPINetworkingManager(baseURL: url, headers: defaultHeader(), addSignature: true)
#if DEBUG
        manager.logging = true
#endif
        return manager
    }
    
    private static func defaultHeader() -> [String: String] {
        var header: [String: String] = ["DEVICE-TYPE": String(GLDeviceType.IOS.rawValue),
                                        "SERVER-MODE": "0"]
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            header.updateValue(version, forKey: "VERSION")
        }
        
        return header
    }
}

// MARK: - GLMP API
extension GLMPNetwork {
    /// Sends a request to the given API with completion and progress handlers.
    ///
    /// - Parameters:
    ///   - apiRequest: The request conforming to `APIEncodableRequest` protocol.
    ///   - headers: Optional headers to include in the request.
    ///   - timeout: The timeout interval for the request. Default is 30 seconds.
    ///   - progress: Optional closure to track the progress of the request.
    ///   - completion: Optional closure to handle the response of the request.
    public static func request<T>(_ apiRequest: T,
                                  timeout: TimeInterval = 30,
                                  progress: ((_ progress: Progress) -> Void)? = nil,
                                  completion: ((_ response: GLMPResponse<T>) -> Void)? = nil)
    where T: APIEncodableRequest, T.Response: APIDecodableResponse {
        guard let manager = self.manager else {
            DispatchQueue.main.async {
                completion?(GLMPResponse<T>(data: nil, error:  GLMPNetworkError.invalidHost.error))
            }
            return
        }
        
        manager.request(apiRequest, headers: getRequestAdditionalHeader(apiRequest), timeout: timeout, progress: { networkingProgress in
            progress?(networkingProgress.progress)
        }, completion: { response in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion?(GLMPResponse<T>(data: nil, error: error))
                    return
                }
                
                if let model = response.processedData as? T.Response {
                    completion?(GLMPResponse<T>(data: model, error: nil))
                } else {
                    completion?(GLMPResponse<T>(data: nil, error: GLMPNetworkError.parsingResponseFailed.error))
                }
            }
        })
    }
    
    /// Sends an asynchronous request to the given API.
    ///
    /// - Parameters:
    ///   - apiRequest: The request conforming to `APIEncodableRequest` protocol.
    ///   - headers: Optional headers to include in the request.
    ///   - timeout: The timeout interval for the request. Default is 30 seconds.
    ///   - progress: Optional closure to track the progress of the request.
    ///
    /// - Returns: A `GLMPResponse` object containing the response data or an error.
    public static func request<T>(_ apiRequest: T,
                                  timeout: TimeInterval = 30,
                                  progress: ((_ progress: Progress) -> Void)? = nil) async -> GLMPResponse<T>
    where T: APIEncodableRequest, T.Response: APIDecodableResponse {
        guard let manager = self.manager else {
            return GLMPResponse<T>(data: nil, error: GLMPNetworkError.invalidHost.error)
        }

        return await withCheckedContinuation { continuation in
            manager.request(apiRequest, headers: getRequestAdditionalHeader(apiRequest), timeout: timeout, progress: { networkingProgress in
                progress?(networkingProgress.progress)
            }, completion: { response in
                DispatchQueue.main.async {
                    if let error = response.error {
                        continuation.resume(returning: GLMPResponse<T>(data: nil, error: error))
                        return
                    }
                    
                    if let model = response.processedData as? T.Response {
                        continuation.resume(returning: GLMPResponse<T>(data: model, error: nil))
                    } else {
                        continuation.resume(returning: GLMPResponse<T>(data: nil, error: GLMPNetworkError.parsingResponseFailed.error))
                    }
                }
            })
        }
    }
    
    
    private static func getRequestAdditionalHeader<T>(_ apiRequest: T) -> [String: String]?
    where T: APIEncodableRequest, T.Response: APIDecodableResponse {
        return requestAdditionalHeaderHandler?(apiRequest)
    }
}
