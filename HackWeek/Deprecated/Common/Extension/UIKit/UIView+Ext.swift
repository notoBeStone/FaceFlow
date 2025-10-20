//
//  UIView+Growth.swift
//  DangJi
//
//  Created by Martin on 2021/12/23.
//  Copyright © 2021 Glority. All rights reserved.
//

import GLImageProcess
import UIKit

// MARK: - Property
extension UIView {
    var gl_cornerRadius: Double {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerCurve = .continuous
            self.layer.cornerRadius = newValue
        }
    }
}

// MARK: - Animation
extension UIView {
    public func shakeAnimation() {
        isHidden = false
        UIView.animate(withDuration: 0.15) {
            self.transform = .init(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.transform = .init(scaleX: 1.0, y: 1.0)
            }
        }
    }

    public func shrinkToThumb(_ thumb: UIView, completion: (() -> Void)? = nil) {
        guard let superView = self.superview else { return }
        let thumbRect = thumb.gl_convertRect(to: superView)
        let newFrame = frame.gl_moveTo(center: thumbRect.gl_center)
        UIView.animate(withDuration: 0.3) {
            self.frame = newFrame
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        } completion: { _ in
            completion?()
        }
    }

    public func scale(_ scale: Double) {
        self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
    }
}

extension UIView {
    func gl_showIn(_ view: UIView, animated: Bool, completion: (() -> Void)? = nil) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if animated {
            self.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
                completion?()
            }
        }
    }

    func gl_dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        self.isUserInteractionEnabled = false

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0.0
            } completion: { _ in
                self.removeFromSuperview()
                completion?()
            }
        } else {
            self.removeFromSuperview()
            completion?()
        }
    }
}

// MARK: - Public Method
extension UIView {
    func addHole(rect: CGRect, radius: Double = 0.0) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        let circlePath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        let path = UIBezierPath(rect: self.bounds)
        path.append(circlePath)
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

// MARK: - Snapshot
extension UIView {
    public func snapshotImage(frame: CGRect) -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        guard let currentImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()

        let width = self.bounds.width
        let height = self.bounds.height
        let x = frame.minX / width * scale
        let y = frame.minY / height * scale
        let cropWidth = frame.width / width * scale
        let cropHeight = frame.height / height * scale
        return GLImageProcess.crop(
            image: currentImage,
            normalizeRect: CGRect(x: x, y: y, width: cropWidth, height: cropHeight)
        )
    }
}
