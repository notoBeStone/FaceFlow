//
//  GLMPResponse.swift
//  GLMP
//
//  Created by xie.longyan on 2024/5/29.
//

import Foundation
import DGMessageAPI

public struct GLMPResponse<T> where T: APIEncodableRequest, T.Response: APIJSONResponse {
    
    public var data: T.Response?
    
    public var error: Error?
    
    public var isCache: Bool = false
    
    public init(data: T.Response? = nil, error: Error? = nil, isCache: Bool = false) {
        self.data = data
        self.error = error
        self.isCache = isCache
    }
}
