//
//  GLMPUpload.swift
//  AINote
//
//  Created by xie.longyan on 2022/12/15.
//

import Foundation
import GLCore
import GLCloudUploader_Extension
import GLAccountExtension
import GLConfig_Extension

extension GLMPUpload {
    public enum UploadType: Int, CaseIterable {  // {$.cloud_uploader_type} 客户端自行配置
        case other
        case screenshot
        case support
        case pdf
        case audio
        case image
        case common
        
        public var scope: String {  // {$.cloud_uploader_scope} 客户端自行配置
            switch self {
                case .other:            return ""
                case .screenshot:       return "user/screenshots"
                case .support:          return "support/support"
                case .pdf:              return "chatbot/chat"
                case .image:            return "chatbot/chat"
                case .audio, .common:        return "chatbot/chat"
            }
        }
        
        public var itemType: String {  // {$.cloud_uploader_itemtype} 客户端自行配置
            switch self {
                case .other:            return ""
                case .pdf:              return ""
                case .image:            return ""
                case .audio, .common:        return ""
                case .screenshot:       return "screenshot"
                case .support:          return "support"
            }
        }
        
        public var disableToMMS: Bool {  // {$.cloud_uploader_mms} 该item 是否禁用上传MMS，客户端自行配置
            switch self {
                case .other:            return true
                case .support:          return true
                case .screenshot:       return false
                case .pdf:              return true
                case .image:            return true
                case .audio, .common:        return true
            }
        }
    }
    
    public enum FileType {
        case none
        case jpg
        case png
        case webp
        case pdf
        case audio(suffix: String)
        case common(extension: String)
        
        public var suffix: String {
            switch self {
                case .none: return ""
                case .jpg: return "jpg"
                case .png: return "png"
                case .webp: return "webp"
                case .pdf: return "pdf"
                case .audio(let suffix): return suffix
                case .common(let ext): return ext
            }
        }
    }
}

public class GLMPUpload: NSObject {
    
    private static let shared = GLMPUpload()
    
    /// 为 `TRUE` 时，先上传 Server，经过 Resize 服务后上传 S3；为 `FALSE` 时，不经过 Server，直接上传至 S3
    private let cloudUploaderNeedServerResize: Bool = false // {$.cloud_uploader_need_server_resize} 客户端自行配置
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: Notification.Name(GLMediator.kUserChangedNotification),
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let self = self else { return }
            self.updateCredentials()
        }
    }
    
    public static func updateCredentials() {
        shared.updateCredentials()
    }
    
    private func updateCredentials() {
        if GL().Account_GetUserId() == nil {
            return
        }
        
        let types = UploadType.allCases
        var scopes: [String] = []
        types.forEach { type in
            scopes.append(type.scope)
        }
        GL().GLConfig_GLOfflineServerConfigUpload(scopes: scopes)
        
        GL().GLCloudUploader_SetUp(needServerResize: cloudUploaderNeedServerResize)
    }
}


extension GLMPUpload {
    public static func upload(data: Data,
                              uploadType: UploadType,
                              fileType: FileType,
                              imageFrom: CloudUploadImageFrom,
                              completion: ((_ url: String?, _ itemId: Int, _ error: Error?) -> (Void))?) {
        upload(data: data,
               uploadType: uploadType,
               suffix: fileType.suffix,
               imageFrom: imageFrom,
               completion: completion)
    }
    
    public static func upload(data: Data,
                              uploadType: UploadType,
                              suffix: String,
                              imageFrom: CloudUploadImageFrom,
                              itemId: String? = nil,
                              completion: ((_ url: String?, _ itemId: Int, _ error: Error?) -> Void)?) {
        upload(data: data,
               imageFrom: imageFrom,
               suffix: suffix,
               scope: uploadType.scope,
               itemType: uploadType.itemType,
               itemId: itemId,
               tags: nil,
               fields: nil,
               disableToMMS: uploadType.disableToMMS,
               completion: completion)
    }
    
    
    //上传图片不入MMS
    public static func upload(data: Data,
                              imageFrom: CloudUploadImageFrom,
                              suffix: String,
                              scope: String,
                              itemType: String,
                              completion: ((_ url: String?, _ itemId: Int, _ error: Error?) -> Void)?) {
        upload(data: data,
               imageFrom: imageFrom,
               suffix: suffix,
               scope: scope,
               itemType: itemType,
               itemId: nil,
               tags: nil,
               fields: nil,
               disableToMMS: true,
               completion: completion)
    }
    
    //上传图片并入MMS
    public static func upload(data: Data,
                              imageFrom: CloudUploadImageFrom,
                              suffix: String,
                              scope: String,
                              itemType: String,
                              itemId: String?,
                              tags: [String]?,
                              fields: [String: Any]?,
                              completion: ((_ url: String?, _ itemId: Int, _ error: Error?) -> Void)?) {
        upload(data: data,
               imageFrom: imageFrom,
               suffix: suffix,
               scope: scope,
               itemType: itemType,
               itemId: nil,
               tags: nil,
               fields: nil,
               disableToMMS: false,
               completion: completion)
    }
    
    //上传高清图片
    
    public static func backgroundUpload(data: Data,
                                        itemId: String,
                                        uploadType: UploadType,
                                        fileType: FileType) {
        GL().GLCloudUploader_BackgroundUpload(data: data,
                                              itemId: itemId,
                                              suffix: fileType.suffix,
                                              scope: uploadType.scope)
    }
    
    private static func upload(data: Data,
                               imageFrom: CloudUploadImageFrom,
                               suffix: String,
                               scope: String,
                               itemType: String,
                               itemId: String?,
                               tags: [String]?,
                               fields: [String: Any]?,
                               disableToMMS: Bool = false,
                               completion: ((_ url: String?, _ itemId: Int, _ error: Error?) -> Void)?) {
        let start = CACurrentMediaTime()
        GL().GLCloudUploader_Upload(data: data,
                                    suffix: suffix,
                                    disableToMMS: disableToMMS,
                                    scope: scope,
                                    itemId: itemId,
                                    itemType: itemType,
                                    tags: tags,
                                    fields: fields,
                                    imageFrom: imageFrom) { fileUrl, itemId, error in
            let end = CACurrentMediaTime()
            if let error = error {
                debugPrint("[GLMPUpload] < \(error.domain) > <size: \(data.count) > <time: \(end - start)>")
            } else {
                debugPrint("[GLMPUpload] < \(fileUrl ?? "NULL") > <size: \(data.count) > <time: \(end - start)>")
            }
            DispatchQueue.main.async {
                completion?(fileUrl, itemId, error)
            }
        }
    }
}
