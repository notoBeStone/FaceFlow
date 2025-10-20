//
//  UIKit+Rotate.swift
//  AINote
//
//  Created by Martin on 2023/2/10.
//

import GLUtils
import UIKit

extension UIApplication {
    static func supportedInterfaceOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientation = orientation
        }
    }

    static func restoreInterfaceOrientation() {
        supportedInterfaceOrientation(.portrait)
        UIDevice.current.rotate(to: .portrait)
    }
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

extension UIInterfaceOrientationMask {
    var deviceOrientation: UIDeviceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}

extension UIDeviceOrientation {
    var orientationMask: UIInterfaceOrientationMask? {
        switch self {
        case .unknown:
            return nil
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .faceUp:
            return nil
        case .faceDown:
            return nil
        @unknown default:
            return .portrait
        }
    }
}

extension UIWindow {
    var isLandscape: Bool? {
        return self.windowScene?.interfaceOrientation.isLandscape
    }
}
