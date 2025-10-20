//
//  GeometryProxy+Ext.swift
//  AINote
//
//  Created by xie.longyan on 2024/9/19.
//

import Foundation
import SwiftUI
import GLUtils

extension GeometryProxy {
    var bottomSheetHeight: CGFloat {
        return self.size.height / 812.0 * (812.0 - max(88.0, self.safeTop + 54.0))
    }
}
