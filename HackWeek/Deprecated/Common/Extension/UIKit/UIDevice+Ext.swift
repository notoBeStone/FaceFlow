//
//  UIDevice.swift
//  DangJi
//
//  Created by Martin on 2022/1/30.
//  Copyright © 2022 Glority. All rights reserved.
//

import GLABTestingExtension
import GLCore
import GLUtils
import UIKit

extension UIDevice {
    @objc public static func impact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    @objc public static func impactLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func rotate(to orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            UIViewController.gl_top().setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            setValue(orientation.deviceOrientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    func rotateToCurrent() {
        if let orientation = self.orientation.orientationMask {
            self.rotate(to: orientation)
        }
    }
}
