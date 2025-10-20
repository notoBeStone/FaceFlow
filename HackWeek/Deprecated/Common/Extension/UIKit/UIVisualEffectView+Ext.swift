//
//  UIView+Growth.swift
//  DangJi
//
//  Created by Martin on 2021/12/23.
//  Copyright © 2021 Glority. All rights reserved.
//

import Foundation
import UIKit

extension UIVisualEffectView {
    static var `default`: UIVisualEffectView {
        let blur = UIBlurEffect(style: .extraLight)
        let view = UIVisualEffectView(effect: blur)
        view.alpha = 0.95
        return view
    }
}
