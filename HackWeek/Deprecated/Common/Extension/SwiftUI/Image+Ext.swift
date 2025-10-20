//
//  Image+Ext.swift
//  AINote
//
//  Created by Martin on 2024/11/18.
//

import SwiftUI

extension Image {
    func size(_ size: CGSize) -> AnyView {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
            .controlSize(.large).anyView
    }
    
    func size(width: Double, height: Double? = nil) -> AnyView {
        let height = height ?? width
        return self.size(CGSize(width: width, height: height))
    }
    
    
    func resizableSquare(_ size: CGFloat) -> some View {
        return self.resizable().frame(width: size, height: size)
    }
}

enum ImageSize {
    case size(_ value: CGSize)
    // h/w
    case hwRate(_ value: Double)
    // w/h
    case whRate(_ value: Double)
}

struct DynamicImage: View {
    let imageName: String
    let imageSize: ImageSize
    @State var readSize: CGSize?
    
    init(imageName: String, imageSize: ImageSize) {
        self.imageName = imageName
        self.imageSize = imageSize
    }
    
    var body: some View {
        if let size = self.size {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width, height: size.height)
                .clipped()
                .readSize { size in
                    self.readSize = size
                }
        } else {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .readSize { size in
                    self.readSize = size
                }
        }
    }
    
    var size: CGSize? {
        switch self.imageSize {
        case .size(let value):
            return value
        case .hwRate(let value):
            if let readSize {
                let h = readSize.width * value
                return .init(width: readSize.width, height: h)
            }
            
        case .whRate(let value):
            if let readSize {
                let w = readSize.height * value
                return .init(width: w, height: readSize.height)
            }
        }
        return nil
    }
}
