//
//  TypingIndicatorView.swift
//  Benji
//
//  Created by Benji Dodgson on 9/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// A `UIView` subclass that holds 3 dots which can be animated
class TypingIndicatorView: View {

    // MARK: - Properties

    /// The offset that each dot will transform by during the bounce animation
    var bounceOffset: CGFloat = 2.5

    /// A convenience accessor for the `backgroundColor` of each dot
    var dotColor: UIColor = Color.lightPurple.color {
        didSet {
            self.dots.forEach { dot in
                dot.backgroundColor = self.dotColor
            }
        }
    }

    /// A flag that determines if the bounce animation is added in `startAnimating()`
    var isBounceEnabled: Bool = true

    /// A flag that determines if the opacity animation is added in `startAnimating()`
    var isFadeEnabled: Bool = true

    /// A flag indicating the animation state
    private(set) var isAnimating: Bool = false

    /// Keys for each animation layer
    private struct AnimationKeys {
        static let offset = "typingIndicator.offset"
        static let bounce = "typingIndicator.bounce"
        static let opacity = "typingIndicator.opacity"
    }

    /// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE to move the dot to the correct
    /// initial offset
    var initialOffsetAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.byValue = -self.bounceOffset
        animation.duration = 0.5
        animation.isRemovedOnCompletion = true
        return animation
    }

    /// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE
    var bounceAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.toValue = -self.bounceOffset
        animation.fromValue = self.bounceOffset
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }

    /// The `CABasicAnimation` applied when `isFadeEnabled` is TRUE
    var opacityAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.5
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }

    // MARK: - Subviews

    let stackView = UIStackView()

    let dots: [BubbleCircleView] = {
        return [BubbleCircleView(), BubbleCircleView(), BubbleCircleView()]
    }()

    // MARK: - Initialization

    override func initializeSubviews() {
        super.initializeSubviews()

        self.dots.forEach { dot in
            dot.backgroundColor = self.dotColor
            dot.heightAnchor.constraint(equalTo: dot.widthAnchor).isActive = true
            self.stackView.addArrangedSubview(dot)
        }
        self.stackView.axis = .horizontal
        self.stackView.alignment = .center
        self.stackView.distribution = .fillEqually
        self.addSubview(self.stackView)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        self.stackView.frame = bounds
        self.stackView.spacing = bounds.width > 0 ? 5 : 0
    }

    // MARK: - Animation API

    /// Sets the state of the `TypingIndicator` to animating and applies animation layers
    func startAnimating() {
        defer { self.isAnimating = true }
        guard !self.isAnimating else { return }
        var delay: TimeInterval = 0
        for dot in self.dots {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let `self` = self else { return }
                if self.isBounceEnabled {
                    dot.layer.add(self.initialOffsetAnimationLayer, forKey: AnimationKeys.offset)
                    let bounceLayer = self.bounceAnimationLayer
                    bounceLayer.timeOffset = delay + 0.33
                    dot.layer.add(bounceLayer, forKey: AnimationKeys.bounce)
                }
                if self.isFadeEnabled {
                    dot.layer.add(self.opacityAnimationLayer, forKey: AnimationKeys.opacity)
                }
            }
            delay += 0.33
        }
    }

    /// Sets the state of the `TypingIndicator` to not animating and removes animation layers
    func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        self.dots.forEach { dot in
            dot.layer.removeAnimation(forKey: AnimationKeys.bounce)
            dot.layer.removeAnimation(forKey: AnimationKeys.opacity)
        }
    }
}
