//
//  GLMPImageCache.swift
//  GLMP
//
//  Created by xie.longyan on 2024/6/13.
//

import Foundation
import GLCore
import GLWebImageExtension

public class GLMPImageCache {
    
    public static func cacheImage(_ image: UIImage, url: String, completion: (() -> Void)? = nil) {
        GL().WebImage_Cache(image: image, to: url)
    }
    
    public static func cacheImage(_ image: UIImage, url: String, completionResult: ((_ success: Bool) -> Void)?) {
        GL().WebImage_Cache(image: image, to: url, completionResult: completionResult)
    }
    
    public static func getCachedImage(url: String, completion: @escaping (_ image: UIImage?) -> Void) {
        GL().WebImage_GetCachedImage(of: url, completion: completion)
    }
    
    public static func getCachedImage(url: String) -> UIImage? {
        if let data = getCachedImageData(url: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    public static func getCachedImageData(url: String) -> Data? {
        return GL().WebImage_GetCachedImageData(from: url)
    }
    
    public static func imageExists(key: String) -> Bool {
        return GL().WebImage_ImageExist(forKey: key)
    }
}
