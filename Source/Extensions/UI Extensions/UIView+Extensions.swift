//
//  UIView+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIView {

    var isVisible: Bool {
        get {
            return !self.isHidden
        }
        set {
            self.isHidden = !newValue
        }
    }

    func makeRound(masksToBounds: Bool = true) {
        self.layer.masksToBounds = masksToBounds
        self.layer.cornerRadius = self.halfHeight
    }

    func roundCorners() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = Theme.cornerRadius
    }

    func round(corners: UIRectCorner, size: CGSize) {
        let maskPath1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: size)
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPath1.cgPath
        self.layer.mask = maskLayer1
    }

    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    func findInSubviews(condition: (UIView) -> Bool) -> UIView? {
        for view in subviews {
            if condition(view) {
                return view
            } else {
                if let result = view.findInSubviews(condition: condition) {
                    return result
                }
            }
        }

        return nil
    }

    func addShadow(withOffset offset: CGFloat) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: offset)
        self.layer.shadowRadius = 10
        self.layer.masksToBounds = false
    }

    func hideShadow() {
        self.layer.shadowOpacity = 0.0
    }

    func contains(_ other: UIView) -> Bool {
        let otherBounds = other.convert(other.bounds, to: nil)
        let selfBounds = self.convert(self.bounds, to: nil)

        return selfBounds.contains(otherBounds)
    }

    func currentFirstResponder() -> UIResponder? {

        if self.isFirstResponder {
            return self
        }

        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }

        return nil
    }

    func set(backgroundColor: Color) {
        self.backgroundColor = backgroundColor.color
    }

    func moveTo(_ x: CGFloat, _ y: CGFloat) {
        self.frame = CGRect(x: x, y: y, width: self.width, height: self.height)
    }

    func moveTo(_ origin: CGPoint) {
        self.moveTo(origin.x, origin.y)
    }

    func subviews<T: UIView>(type : T.Type) -> [T] {

        var matchingViews: [T] = []

        for view in self.subviews {
            if let view = view as? T {
                matchingViews.append(view)
            }
        }

        return matchingViews
    }
}

