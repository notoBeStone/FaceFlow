//
//  NSRange+Ext.swift
//  IOSProject
//
//  Created by Martin on 2024/3/14.
//

import Foundation

extension NSRange {
    var max: Int {
        return self.location + self.length
    }
}
