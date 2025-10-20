//
//  AdjustConfigItem.swift
//  GLModules
//
//  Created by user on 2024/6/21.
//

import Foundation
import GLCore
import GLAdjustExtension
import GLMP
import GLTrackingExtension


public protocol AdjustConfigItemProtocol: WorkflowItem {
    func adjustDeeplinkHandler(_ url: URL?)
}

public extension AdjustConfigItemProtocol {
    
    func execute(_ context: WorkflowContext, completion: @escaping (WorkflowContext) -> Void) {
        GL().Adjust_AppDidLaunch()
        GL().Adjust_RegisterDeferredDeeplink { url in      //处理Adjust deeplink
            //todo
            adjustDeeplinkHandler(url)
        }
        
        GL().Adjust_FetchAdjustAttributionCompletion { attribution in    //处理Adjust 归因回调
            GLMPTracking.tracking("adjustfetchattribution_exposure", parameters: [
                GLT_PARAM_STRING1: attribution?.campaign ?? "",
                GLT_PARAM_STRING2: attribution?.creative ?? "",
                GLT_PARAM_STRING3: attribution?.adgroup ?? ""
            ])
        }
        completion(context)
    }

}

class AdjustConfigItem: AdjustConfigItemProtocol {
    func adjustDeeplinkHandler(_ url: URL?) { }
}
