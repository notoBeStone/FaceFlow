//
//  APIDebug.swift
//  AppModels
//
//  Created by xie.longyan on 2024/8/27.
//

import Foundation
import GLMP
import DGMessageAPI
import AppModels

#if DEBUG
extension APIDebug {
    public static func debug<T>(
        _ enable: Bool,
        duration: Double = 1.0,
        json: String,
        type: T.Type
    ) async -> GLMPResponse<T>? where T: APIEncodableRequest, T.Response: APIJSONResponse {
        if enable, let response = GLJSON.toModel(jsonString: json, type: T.Response.self) {
            await sleep(duration)
            return GLMPResponse<T>(data: response)
        }
        return nil
    }
    
    public static func debug<T>(
        _ enable: Bool,
        duration: Double,
        json: String
    ) async -> GLMPResponse<T>? where T: APIEncodableRequest, T.Response: APIJSONResponse {
        if enable, let response = GLJSON.toModel(jsonString: json, type: T.Response.self) {
            await sleep(duration)
            return GLMPResponse<T>(data: response)
        }
        return nil
    }
}
#endif
