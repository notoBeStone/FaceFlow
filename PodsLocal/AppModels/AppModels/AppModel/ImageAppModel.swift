//
//  ImageAppModel.swift
//  AINote
//
//  Created by user on 2024/4/10.
//

import Foundation
import GLBaseApi
import DGMessageAPI
import GLImageProcess
import GLCore
import GLWebImageExtension
import GLNetworking

public class ImageAppModel: Codable {
    
    public let image: UIImage
    
    /**
     * 图片来源：后摄像头，前摄像头，相册
     */
    public let from: PhotoFrom
    
    /**
     * 照片拍摄的时间, 没有拍摄时间则不传
     */
    public let shootAt: Date?
    
    /**
     * 拍摄坐标, 没有拍摄坐标则不传
     */
    
    public let shootLocation: LocationModel?
    
    /// 识别短边
    let recognizeMinLength: CGFloat = 448
    
    
    enum CodingKeys: CodingKey {
        case from
        case shootAt
        case shootLocation
        case imageData
    }
    
    
    public init(image: UIImage, from: PhotoFrom, shootAt: Date? = nil, shootLocation: LocationModel? = nil) {
        self.image = image
        self.from = from
        self.shootAt = shootAt
        self.shootLocation = shootLocation
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.from, forKey: .from)
        try container.encodeIfPresent(self.shootAt, forKey: .shootAt)
        try container.encodeIfPresent(self.shootLocation, forKey: .shootLocation)
        if let imageData = try? image.toData() {
            try container.encode(imageData, forKey: .imageData)
        }
       
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.from = try container.decode(PhotoFrom.self, forKey: .from)
        self.shootAt = try container.decodeIfPresent(Date.self, forKey: .shootAt)
        self.shootLocation = try container.decodeIfPresent(LocationModel.self, forKey: .shootLocation)
        if let imageData = try container.decode(Data.self, forKey: .imageData) as? Data {
            self.image = UIImage(data: imageData) ?? UIImage()
        } else {
            self.image = UIImage()
        }
    }
        
    public func getRecognizeImage() -> UIImage? {
        return GLImageProcess.resize(image: image, minLength: recognizeMinLength)
    }

    public func getRecognizeImageData() -> Data? {
        let qualityFactor = GLNetworkingReachabilityTool.isHighQualityNetwork ? 0.9 : 0.7
        return getRecognizeImage()?.jpegData(compressionQuality: qualityFactor)
    }
}


extension UIImage: APIFile {
    
    public func toData() throws -> Data {
        return self.jpegData(compressionQuality: 1.0) ?? Data()
    }
}


extension ImageAppModel {
    public func toImageOrImageUrlAppModel() -> ImageOrImageUrlAppModel {
        return ImageOrImageUrlAppModel(image: image, from: from, shootAt: shootAt, shootLocation: shootLocation)
    }
}
