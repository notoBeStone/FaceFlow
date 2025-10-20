//
//  BrowserImage.swift
//  GLCMSResult
//
//  Created by user on 2024/5/13.
//

import UIKit
import GLWidget
import GLComponentAPI

public class BrowserImage {
    // Choose either imageURL or image, not both
    public var imageURL: String?
    public var image: UIImage?
    
    public var cpyRight: GLImageBrowserAdditionalInfo?
    public var brief: String?
    public var tip: String?
    
    public init() {
        
    }
    
    public init(uiImage: UIImage) {
        self.image = uiImage
    }

    public init(cmsImage: CmsImageModel) {
        self.imageURL = cmsImage.imageUrl
        self.tip = cmsImage.comment
        if let imageCopyright = cmsImage.imageCopyright {
            let cpyRight = GLImageBrowserAdditionalInfo(signature: imageCopyright.author,
                                                        certUrl: imageCopyright.certUrl,
                                                        detailUrl: imageCopyright.detailUrl,
                                                        authorlink: imageCopyright.authorlink,
                                                        license: imageCopyright.license,
                                                        notes: "")
            self.cpyRight = cpyRight.isValid ? cpyRight : nil
        }
    }
}
