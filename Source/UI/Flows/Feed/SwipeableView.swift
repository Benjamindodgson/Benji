//
//  SwipeableView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol SwipeableViewDelegate: class {
    func swipeableViewSelected(_ view: SwipeableView)
    func swipeableViewDidBeginSwipe(_ view: SwipeableView)
    func swipeableViewDidEndSwipe(_ view: SwipeableView)
}

class SwipeableView: View {

    var delegate: SwipeableViewDelegate?

    private var panGestureTranslation: CGPoint = .zero

    // MARK: Drag Animation Settings

    let resetAnimator = UIViewPropertyAnimator(duration: 0.4,
                                               dampingRatio: 0.7,
                                               animations: nil)

    var maximumRotation: CGFloat = 1.0
    var rotationAngle: CGFloat = CGFloat(Double.pi) / 10.0
    var animationDirectionY: CGFloat = 1.0
    var swipePercentageMargin: CGFloat = 0.7

    override func initialize() {
        self.isUserInteractionEnabled = true
        // Pan Gesture Recognizer
        self.onPan { [unowned self] (pan) in
            self.handle(pan)
        }

        // Tap Gesture Recognizer
        self.onTap { [unowned self] (tap) in
            self.delegate?.swipeableViewSelected(self)
        }
    }

    // MARK: - Pan Gesture Recognizer

    private func handle(_ pan: UIPanGestureRecognizer) {
        self.panGestureTranslation = pan.translation(in: self)

        switch pan.state {
        case .began:
            let initialTouchPoint = pan.location(in: self)
            let newAnchorPoint = CGPoint(x: initialTouchPoint.x / self.width, y: initialTouchPoint.y / self.height)
            let oldPosition = CGPoint(x: self.width * self.layer.anchorPoint.x, y: self.height * self.layer.anchorPoint.y)
            let newPosition = CGPoint(x: self.width * newAnchorPoint.x, y: self.height * newAnchorPoint.y)
            self.layer.anchorPoint = newAnchorPoint
            self.layer.position = CGPoint(x: self.layer.position.x - oldPosition.x + newPosition.x, y: self.layer.position.y - oldPosition.y + newPosition.y)

            self.layer.rasterizationScale = UIScreen.main.scale
            self.layer.shouldRasterize = true
            self.delegate?.swipeableViewDidBeginSwipe(self)
        case .changed:
            let rotationStrength = min(self.panGestureTranslation.x / self.width, self.maximumRotation)
            let rotationAngle = self.animationDirectionY * self.rotationAngle * rotationStrength

            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
            transform = CATransform3DTranslate(transform, self.panGestureTranslation.x, self.panGestureTranslation.y, 0)
            self.layer.transform = transform
        case .ended:
            self.endedPanAnimation()
            self.layer.shouldRasterize = false
        default:
            self.resetCardViewPosition()
            self.layer.shouldRasterize = false
        }
    }

    private var dragDirection: SwipeDirection? {
        let normalizedDragPoint = self.panGestureTranslation.normalizedDistanceForSize(self.bounds.size)
        return SwipeDirection.allDirections.reduce((distance: CGFloat.infinity, direction: nil), { closest, direction -> (CGFloat, SwipeDirection?) in
            let distance = direction.point.distanceTo(normalizedDragPoint)
            if distance < closest.distance {
                return (distance, direction)
            }
            return closest
        }).direction
    }

    private var dragPercentage: CGFloat {
        guard let dragDirection = self.dragDirection else { return 0.0 }

        let normalizedDragPoint = self.panGestureTranslation.normalizedDistanceForSize(frame.size)
        let swipePoint = normalizedDragPoint.scalarProjectionPointWith(dragDirection.point)

        let rect = SwipeDirection.boundsRect

        if !rect.contains(swipePoint) {
            return 1.0
        } else {
            let centerDistance = swipePoint.distanceTo(.zero)
            let targetLine = (swipePoint, CGPoint.zero)

            return rect.perimeterLines
                .compactMap { line in
                    CGPoint.intersectionBetweenLines(targetLine, line2: line)
                }
                .map { point in
                    centerDistance / point.distanceTo(.zero)
                }
                .min() ?? 0.0
        }
    }

    private func endedPanAnimation() {
        if self.dragDirection != nil, self.dragPercentage >= self.swipePercentageMargin {
            self.delegate?.swipeableViewDidEndSwipe(self)
            self.resetCardViewPosition()
        } else {
            self.resetCardViewPosition()
        }
    }

    private func animationPointForDirection(_ direction: SwipeDirection) -> CGPoint {
        let point = direction.point
        let animatePoint = CGPoint(x: point.x * 4, y: point.y * 4)
        let retPoint = animatePoint.screenPointForSize(UIScreen.main.bounds.size)
        return retPoint
    }

    private func resetCardViewPosition() {
        self.resetAnimator.stopAnimation(true)
        self.resetAnimator.addAnimations {
            self.layer.transform = CATransform3DIdentity
        }

        self.resetAnimator.startAnimation()
    }
}
