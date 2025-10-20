//
//  ImageOrImageUrlAppModel.swift
//  AppModels
//
//  Created by 彭瑞淋 on 2024/10/11.
//

import Foundation
import GLBaseApi
import DGMessageAPI

public struct LocationModel: APIModel {
    public var longitude: Double

    public var latitude: Double

    enum CodingKeys: String, CodingKey {
        case longitude = "longitude"

        case latitude = "latitude"
    }
    
    public init(
            longitude: Double,
            latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

public class ImageOrImageUrlAppModel: ObservableObject {
    
    public var image: UIImage? = nil
    
    
    public var imageUrl: String? = nil
    /*
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
    
    /// 上传图片后获得的 itemid
    public var itemId: Int? = nil
    
    public init(image: UIImage, from: PhotoFrom, shootAt: Date? = nil, shootLocation: LocationModel? = nil) {
        self.image = image
        self.from = from
        self.shootAt = shootAt
        self.shootLocation = shootLocation
    }
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
        self.from = .album
        self.shootAt = nil
        self.shootLocation = nil
    }
    
}
