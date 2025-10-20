//
//  UIImageView+Growth.swift
//  PictureProjectCommon
//
//  Created by Martin on 2022/7/8.
//

import GLCore
import UIKit

extension UIImageView {
    convenience public init(name: String, mode: UIView.ContentMode = .scaleAspectFit) {
        var image: UIImage? = nil
        if !name.isEmpty {
            image = UIImage(named: name)
        }
        self.init(image: image)
        self.contentMode = mode
        self.clipsToBounds = true
    }
}

extension UIImage {
    func blur(value: Double = 25.0) -> UIImage? {
        guard let aCIImage = CIImage(image: self) else {
            return nil
        }
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter?.setDefaults()
        clampFilter?.setValue(aCIImage, forKey: kCIInputImageKey)

        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(clampFilter?.outputImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(value, forKey: kCIInputRadiusKey)

        let rect = aCIImage.extent
        if let output = blurFilter?.outputImage {
            let context = CIContext(options: nil)
            if let cgimg = context.createCGImage(output, from: rect) {
                let processedImage = UIImage(cgImage: cgimg)
                return processedImage
            }
        }
        return nil
    }
}
