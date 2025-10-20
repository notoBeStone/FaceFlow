//
//  UISwitch+Ext.swift
//  AINote
//
//  Created by Martin on 2023/8/16.
//

import UIKit

extension UISwitch {
    convenience init(on: Bool) {
        self.init()
        self.onTintColor = .themeColor
        self.isOn = on
    }
}
