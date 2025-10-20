//
//  ManageSubDefaultLayout.swift
//  GLMSubDefault
//
//  Created by user on 2023/10/20.
//

import UIKit

@objc public class ResponsiveLayout: NSObject {
    private override init() {
        // do nothing
    }
    static private let shared = ResponsiveLayout.init()

    @objc var scale: CGFloat {
        UIScreen.main.scale
    }
    
    var _sampleWidth: CGFloat = 375
    var _ipadWidth: CGFloat = 643
    lazy var _ratio: CGFloat = UIScreen.main.bounds.width / (UIDevice.current.userInterfaceIdiom == .pad ? _ipadWidth : _sampleWidth)
    
    /// 视觉稿的 sample 宽度, default is 375
    @objc static public var sampleWith: CGFloat {
        get { ResponsiveLayout.shared._sampleWidth }
        set {
            ResponsiveLayout.shared._sampleWidth = newValue
            ResponsiveLayout.shared._ratio = UIScreen.main.bounds.width / ResponsiveLayout.shared._sampleWidth
        }
    }
    
    @objc static public var ipadWidth: CGFloat {
        get { ResponsiveLayout.shared._ipadWidth }
        set {
            ResponsiveLayout.shared._ipadWidth = newValue
            ResponsiveLayout.shared._ratio = UIScreen.main.bounds.width / ResponsiveLayout.shared._ipadWidth
        }
    }
    
    /// default means width ratio
    @objc static public var ratio: CGFloat {
        get { ResponsiveLayout.shared._ratio }
    }

}

public extension CGFloat {
    var rpt:CGFloat {
        get {
            return self * ResponsiveLayout.ratio
        }
    }
    
    func rpt(ipad: CGFloat) -> CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? ipad : self * ResponsiveLayout.ratio
    }
}

public extension Int {
    var rpt:CGFloat {
        get {
            return CGFloat(self) * ResponsiveLayout.ratio
        }
    }
    
    func rpt(ipad: CGFloat) -> CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? ipad : CGFloat(self) * ResponsiveLayout.ratio
    }
}

public extension Double {
    var rpt:CGFloat {
        get {
            return self * ResponsiveLayout.ratio
        }
    }
    
    func rpt(ipad: CGFloat) -> CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? ipad : self * ResponsiveLayout.ratio
    }
}

