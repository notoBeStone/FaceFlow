//
//  ConfigApis.swift
//  AppRepository
//
//  Created by user on 2024/5/21.
//

import Foundation
import DGMessageAPI
import GLComponentAPI
import GLMP


public class SupportApis {
    

    public static func sendSupportTicket(email: String, 
                                         content: String?,
                                         imageUrls: [String]?,
                                         type: SupportType,
                                         tags: [String]? = nil,
                                         extraFields:  [String: Any]? = nil, completion: @escaping (GLMPResponse<SupportSendSupportTicketRequest>) -> Void) {
        
        let fields: [String: AnyCodable]? = extraFields?.mapValues({ AnyCodable($0) })
        let request = SupportSendSupportTicketRequest(email: email, 
                                                      supportType: type,
                                                      languageCode: GLMPAppUtil.languageCode,
                                                      countryCode: GLMPAppUtil.countryCode,
                                                      content: content,
                                                      images: imageUrls,
                                                      tags: tags,
                                                      extraFields: fields)
        
        GLMPNetwork.request(request, completion: completion)
    }
}
