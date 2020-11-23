//
//  UIView+Layout.swift
//  Benji
//
//  Created by Benji Dodgson on 3/15/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum ViewSide {
    case top
    case bottom
    case left
    case right
}

extension UIView {

    var top: CGFloat {
        get {
            return self.frame.origin.y
        }

        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var x: CGFloat {
        get {
            return self.frame.origin.x
        }

        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var y: CGFloat {
        get {
            return self.frame.origin.y
        }

        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var left: CGFloat {
        get {
            return self.frame.origin.x
        }

        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }

        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }

    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }

        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }

    var centerX: CGFloat {
        get {
            return self.center.x
        }

        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }

    var centerY: CGFloat {
        get {
            return self.center.y
        }

        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }

    func centerOnXAndY() {
        self.centerOnY()
        self.centerOnX()
    }

    func centerOnY() {
        if let theSuperView = self.superview {
            self.centerY = theSuperView.halfHeight
        }
    }

    func centerOnX() {
        if let theSuperView = self.superview {
            self.centerX = theSuperView.halfWidth
        }
    }

    var width: CGFloat {
        get {
            return self.frame.size.width
        }

        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        }

        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    var halfWidth: CGFloat {
        get {
            return 0.5*self.frame.size.width
        }
    }

    var halfHeight: CGFloat {
        get {
            return 0.5*self.frame.size.height
        }
    }

    /// Sets the width of the view to the superview's width and positions it at the far left
    func expandToSuperviewWidth() {
        guard let superview = self.superview else { return }
        self.width = superview.width
        self.left = 0
    }

    /// Sets the height of the view to the superview's heigth and positions it at the top
    func expandToSuperviewHeight() {
        guard let superview = self.superview else { return }
        self.height = superview.height
        self.top = 0
    }

    /// Completely fills this view's superview by setting the frame to the superview's bounds.
    func expandToSuperviewSize() {
        guard let superview = self.superview else { return }
        self.frame = superview.bounds
    }

    var origin: CGPoint {
        get {
            return self.frame.origin
        }

        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }

    var size: CGSize {
        get {
            return CGSize(width: self.width, height: self.height)
        }

        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }

    var squaredSize: CGFloat {
        get {
            return self.size.height
        }
        set {
            self.width = newValue
            self.height = newValue
        }
    }

    /// The rect, in this view's coordinate space, that is within the bounds of the safe area.
    var safeAreaRect: CGRect  {
        get {
            let safeInsets = self.safeAreaInsets
            return CGRect(x: safeInsets.left,
                          y: safeInsets.top,
                          width: self.bounds.width - safeInsets.left - safeAreaInsets.right,
                          height: self.bounds.height - safeInsets.top - safeInsets.bottom)
        }
    }

    /// Forces the view to layout immediately, regardless of the needsLayout flag status.
    func layoutNow() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    /// Pins the specified side of the view to the same side of its superview with optional padding space.
    /// The view's size remains unchanged. If the view has no superview, this function does nothing.
    func pin(_ side: ViewSide, padding: CGFloat = 0) {
        guard let superview = self.superview else { return }

        switch side {
        case .top:
            self.top = padding
        case .bottom:
            self.bottom = superview.height - padding
        case .left:
            self.left = padding
        case .right:
            self.right = superview.width - padding
        }
    }

    /// Pins the specified side of the view to the same side of its superview's safe area with optional padding space.
    /// The view's size remains unchanged. If the view has no superview, this function does nothing.
    func pinToSafeArea(_ side: ViewSide, padding: CGFloat) {
        guard let superview = self.superview else { return }
        let superSafeAreaRect = superview.safeAreaRect

        switch side {
        case .top:
            self.top = superSafeAreaRect.minY + padding
        case .bottom:
            self.bottom = superSafeAreaRect.maxY - padding
        case .left:
            self.left = superSafeAreaRect.minX + padding
        case .right:
            self.right = superSafeAreaRect.maxX - padding
        }
    }

    /// Sets the specified side's value to be equal to the side of another view, minus an offset value.
    /// The view's size remains unchanged.
    func match(_ side: ViewSide,
               to toSide: ViewSide,
               of view: UIView,
               offset: CGFloat = 0) {

        let toSideValue: CGFloat

        switch toSide {
        case .top:
            toSideValue = view.top
        case .bottom:
            toSideValue = view.bottom
        case .left:
            toSideValue = view.left
        case .right:
            toSideValue = view.right
        }

        switch side {
        case .top:
            self.top = toSideValue + offset
        case .bottom:
            self.bottom = toSideValue + offset
        case .left:
            self.left = toSideValue + offset
        case .right:
            self.right = toSideValue + offset
        }
    }

    /// Fully expands the view in the direction of superview's specified side. Optionally provide a padding value.
    /// The view's size will be affected. It's origin may be affected for top and left expansion.
    /// If the view has no superview, this function does nothing.
    func expand(_ side: ViewSide, padding: CGFloat = 0) {
        guard let superview = self.superview else { return }

        switch side {
        case .top:
            self.height += self.top - padding
            self.top = padding
        case .bottom:
            self.height = superview.height - self.top - padding
        case .left:
            self.width += self.left - padding
            self.left = padding
        case .right:
            self.width = superview.width - self.left - padding
        }
    }

    /// Expands the view in the specified direction to a given value, minus an offset.
    /// The view's size will be affected. It's origin may be affected for top and left expansion.
    func expand(_ side: ViewSide,
                to value: CGFloat,
                offset: CGFloat = 0) {

        switch side {
        case .top:
            var newFrame = self.frame
            newFrame.size.height += newFrame.minY - value + offset
            newFrame.origin.y = value + offset
            self.frame = newFrame
        case .bottom:
            self.height += value - self.bottom + offset
        case .left:
            var newFrame = self.frame
            newFrame.size.width += newFrame.minX - value + offset
            newFrame.origin.x = value + offset
            self.frame = newFrame
        case .right:
            self.width += value - self.right + offset
        }
    }

    var proportionalWidth: CGFloat {
        return self.width * 0.8
    }
}

