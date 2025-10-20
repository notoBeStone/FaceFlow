//
//  GLMPUpload+Ext.swift
//  AINote
//
//  Created by user on 2024/8/13.
//

import Foundation
import GLMP
import AppModels
import GLImageProcess
import DGMessageAPI
import GLCloudUploader_Extension

extension PhotoFrom {
    var uploadImageFrom: CloudUploadImageFrom? {
        switch self {
        case .backCamera:
            return .backCamera
        case .frontCamera:
            return .frontCamera
        case .album:
            return .album
        default:
            return nil
        }
    }
}

extension GLMPUpload {
    
    private static let dispatchQueueLabel = "AINote.imageuploadqueue"
    
    public class func uploadImages(_ imageModels: [ImageAppModel],
                                   uploadType: GLMPUpload.UploadType,
                                   fileType: GLMPUpload.FileType = .jpg,
                                   tags: [String]? = nil,
                                   fields: [String: Any]? = nil,
                                   completion: @escaping (Bool, [(String, Int)]) -> Void) {
        let fileType: GLMPUpload.FileType = .jpg
        let queue = DispatchQueue(label: dispatchQueueLabel, attributes: .concurrent)
        let group = DispatchGroup()
        var results: [(String, Int)] = []
        
        imageModels.forEach { model in
            group.enter()
            queue.async {
                if let sizedImage = GLImageProcess.resize(image: model.image, minLength: 720),
                   let data = sizedImage.gl_fixOrientation().jpegData(compressionQuality: 0.8) {
                    
                    GLMPUpload.upload(data: data, imageFrom: model.from.uploadImageFrom ?? .album, suffix: fileType.suffix, scope: uploadType.scope, itemType: uploadType.itemType, itemId: nil, tags: tags, fields: fields) { url, itemId, error in
                        if error == nil,  let url = url {
                            results.append((url, itemId))
                        }
                        group.leave()
                    }
                    
                } else {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(results.count == imageModels.count, results)
        }
    }
    
    public class func uploadImagesAsync(_ imageModels: [ImageAppModel],
                                        uploadType: GLMPUpload.UploadType,
                                        fileType: GLMPUpload.FileType = .jpg,
                                        tags: [String]? = nil,
                                        fields: [String: Any]? = nil) async -> (Bool, [(String, Int)]) {
        await withCheckedContinuation { continuation in
            uploadImages(imageModels, uploadType: uploadType, fileType: fileType, tags: tags, fields: fields) { success, results in
                continuation.resume(returning: (success, results))
            }
        }
    }

    /// 用于上传带有图片 URL
    public class func uploadimageOrUrl(_ imageOrUrlModels: [ImageOrImageUrlAppModel],
                                       uploadType: GLMPUpload.UploadType,
                                       fileType: GLMPUpload.FileType = .jpg,
                                       tags: [String]? = nil,
                                       fields: [String: Any]? = nil,
                                       completion: @escaping (Bool, [ImageOrImageUrlAppModel]) -> Void) {
        if imageOrUrlModels.count == 0 {
            completion(true, imageOrUrlModels)
            return
        }
        
        let fileType: GLMPUpload.FileType = .jpg
        let queue = DispatchQueue(label: dispatchQueueLabel, attributes: .concurrent)
        let group = DispatchGroup()
        
        imageOrUrlModels.forEach { model in
            group.enter()
            queue.async {
                if let image = model.image {
                    if let sizedImage = GLImageProcess.resize(image: image, minLength: 720),
                       let data = sizedImage.gl_fixOrientation().jpegData(compressionQuality: 0.7) {
                        
                        GLMPUpload.upload(data: data, imageFrom: model.from.uploadImageFrom ?? .album, suffix: fileType.suffix, scope: uploadType.scope, itemType: uploadType.itemType, itemId: nil, tags: tags, fields: fields) { url, itemId, error in
                            model.itemId = itemId
                            model.imageUrl = url
                            model.image = nil
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(imageOrUrlModels.first(where: { $0.image != nil }) == nil, imageOrUrlModels)
        }
    }
    
    public class func uploadimageOrUrl(_ imageOrUrlModels: [ImageOrImageUrlAppModel],
                                       uploadType: GLMPUpload.UploadType,
                                       fileType: GLMPUpload.FileType = .jpg,
                                       tags: [String]? = nil,
                                       fields: [String: Any]? = nil) async -> (Bool, [ImageOrImageUrlAppModel]) {
        await withCheckedContinuation { continuation in
            uploadimageOrUrl(imageOrUrlModels, uploadType: uploadType, fileType: fileType, tags: tags, fields: fields) { success, results in
                continuation.resume(returning: (success, results))
            }
        }
    }
}
