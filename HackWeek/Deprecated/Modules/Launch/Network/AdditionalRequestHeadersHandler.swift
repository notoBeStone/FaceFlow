//
//  AdditionalRequestHeadersHandler.swift
//  AINote
//
//  Created by user on 2024/7/3.
//

import UIKit
import GLModules
import DGMessageAPI
import AppModels
import GLMP
import GLComponentAPI

class AdditionalRequestHeadersHandler: NetworkHeaderConfigItemProtocol {
    
    static func requestHeaderHander(_ request: any APIEncodableRequest) -> [String : String]? {
        return requestAdditionalHeaders(request)
    }
    
    //特殊请求的header添加处理， 根据apiRequest的类型去修改
    private static func requestAdditionalHeaders<T>(_ apiRequest: T) -> [String: String]? where T: APIEncodableRequest {
        var header: [String: String] = [:]
        if engineRequestTypes.contains(where: { $0 == type(of: apiRequest) }) {
            header.merge(identificationEngineHeader()) { _, new in new }
        }
        
        if h5RequestTypes.contains(where: { $0 == type(of: apiRequest) }) {
            header.merge(H5WebContentHeader()) { _, new in new }
        }
        
        if h5CareRequestTypes.contains(where: { $0 == type(of: apiRequest) }) {
            header.merge(H5CareWebContentHeader()) { _, new in new }
        }
        
        return header
    }
    
    
    private static func identificationEngineHeader() -> [String: String] {
        return [:]
//        let abtestingModels = GLMPABTesting.queryABTestingModels("engine-abtesting-", activte: true)
//
//        var header: [String: String] = [:]
//
//        abtestingModels.forEach { model in
//            let key = model.abtestingKey.uppercased()
//            if let variableData = model.variableData, !key.isEmpty {
//                header[key] = variableData
//
//                let abtestingID = model.abtestingID
//                if !abtestingID.isEmpty, let value = abtestingID.data(using: .utf8)?.base64EncodedString() {
//                    let base64Key = key.replacingOccurrences(of: "ABTESTING", with: "ABNAME") + "-BASE64"
//                    header[base64Key] = value
//                }
//            }
//        }
//        return header
    }
    
    private static func H5WebContentHeader() -> [String: String] {
        return [:]
//        var header: [String: String] = [:]
//        
//        header["ABTESTING-CMS"] = "name_h5=v17"
//        
//        return header
    }
    
    private static func H5CareWebContentHeader() -> [String: String] {
        return [:]
//        var header: [String: String] = [:]
//        
//        header["ABTESTING-CMS"] = "plant_care_info=v17"
//        
//        return header
    }
    
    static let engineRequestTypes: [any APIEncodableRequest.Type] = [
//        RecognizeIdentifyRequest.self,
//        DiagnosisDiagnoseRequest.self,
//        DiagnosisWateringAmountCalculationRequest.self,
//        DiagnosisRePotCheckRequest.self,
//        RecognizeOtherSpeciesIdentifyRequest.self
    ]
    
    static let h5RequestTypes: [any APIEncodableRequest.Type] = [
//        RecognizeIdentifyRequest.self,
//        RecognizeGetIdentificationPlantRequest.self,
//        CmsGetCmsNameRequest.self,
//        RecognizeIdentifySampleRequest.self,
    ]
    
    static let h5CareRequestTypes: [any APIEncodableRequest.Type] = [
//        CmsGetStaticUrlRequest.self,
    ]
}
