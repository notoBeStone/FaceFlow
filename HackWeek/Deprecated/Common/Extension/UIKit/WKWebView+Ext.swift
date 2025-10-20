//
//  WKWebView+Extension.swift
//  AINote
//
//  Created by Martin on 2022/10/20.
//

import WebKit

extension WKWebView {
    
    func getDocumentAppElementScrollHeight(completion: @escaping ((Bool, CGFloat) -> Void)) {
        self.evaluateJavaScript("document.getElementById('app')?(document.getElementById('app').scrollHeight):(document.scrollingElement.scrollHeight)") { result, error in
            if let _ = error {
                completion(false, 0)
            } else if let height = result as? NSNumber {
                completion(true, CGFloat(height.floatValue))
            }
        }
    }
}
