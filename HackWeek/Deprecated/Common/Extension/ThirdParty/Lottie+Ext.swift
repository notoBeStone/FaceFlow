//
//  Lottie+Ext.swift
//  AINote
//
//  Created by Martin on 2024/11/12.
//

import Foundation
import Lottie
import GLUtils
import SwiftUI

struct LottieReplaceItem {
    let source: String
    let destination: String
}

extension LottieView {
    static func lottieView(name: String, replaceItems: [LottieReplaceItem], imageNames: [String]) -> LottieView<EmptyView>? {
        guard let path = Bundle.main.path(forResource: name, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let jsonText = String(data: data, encoding: .utf8) as? NSString else {
            return nil
        }
        
        let mutJsonText = NSMutableString(string: jsonText)
        replaceItems.forEach { item in
            mutJsonText.replaceOccurrences(of: item.source, with: item.destination, range: .init(location: 0, length: mutJsonText.length))
        }
        let randome = UUID().uuidString + CFAbsoluteTimeGetCurrent().gl_reserveText(decimal: 0)
        let dir = GLSandBox.tmpPath().appendFile(component: randome)
        if !FileManager.default.fileExists(atPath: dir) {
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        }
        imageNames.forEach { imageName in
            if let data = UIImage(named: imageName)?.pngData() {
                let filePath = dir.appendFile(component: "\(imageName).png")
                try? data.write(to: URL(fileURLWithPath: filePath))
            }
        }
        if let data = mutJsonText.data(using: NSUTF8StringEncoding) {
            let filePath = dir.appendFile(component: "\(name).json")
            try? data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            do {
                try data.write(to: URL(fileURLWithPath: filePath))
                return LottieView<EmptyView>(animation: .filepath(filePath))
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
