//
//  TypingBubbleView.swift
//  Benji
//
//  Created by Benji Dodgson on 9/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// A subclass of `UIView` that mimics the iMessage typing bubble
class TypingBubbleView: View {

    // MARK: - Properties

    var isPulseEnabled: Bool = true

    private(set) var isAnimating: Bool = false

    override var backgroundColor: UIColor? {
        set {
            [self.contentBubble, self.cornerBubble, self.tinyBubble].forEach { bubble in
                bubble.backgroundColor = newValue
            }
        }
        get {
            return self.contentBubble.backgroundColor
        }
    }

    private struct AnimationKeys {
        static let pulse = "typingBubble.pulse"
    }

    // MARK: - Subviews

    /// The indicator used to display the typing animation.
    let typingIndicator = TypingIndicatorView()
    let contentBubble = UIView()
    let cornerBubble = BubbleCircleView()
    let tinyBubble = BubbleCircleView()

    // MARK: - Animation Layers

    var contentPulseAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.04
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }

    var circlePulseAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.1
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.tinyBubble)
        self.addSubview(self.cornerBubble)
        self.addSubview(self.contentBubble)
        self.contentBubble.addSubview(self.typingIndicator)
        self.set(backgroundColor: .purple)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // To maintain the iMessage like bubble the width:height ratio of the frame
        // must be close to 1.65
        let ratio = self.bounds.width / self.bounds.height
        let extraRightInset = self.bounds.width - 1.65/ratio * self.bounds.width

        let tinyBubbleRadius: CGFloat = self.bounds.height / 6
        self.tinyBubble.frame = CGRect(x: 0,
                                       y: self.bounds.height - tinyBubbleRadius,
                                       width: tinyBubbleRadius,
                                       height: tinyBubbleRadius)

        let cornerBubbleRadius = tinyBubbleRadius * 2
        let offset: CGFloat = tinyBubbleRadius / 6
        self.cornerBubble.frame = CGRect(x: tinyBubbleRadius - offset,
                                         y: self.bounds.height - (1.5 * cornerBubbleRadius) + offset,
                                         width: cornerBubbleRadius,
                                         height: cornerBubbleRadius)

        let contentBubbleFrame = CGRect(x: tinyBubbleRadius + offset,
                                        y: 0,
                                        width: self.bounds.width - (tinyBubbleRadius + offset) - extraRightInset,
                                        height: self.bounds.height - (tinyBubbleRadius + offset))
        let contentBubbleFrameCornerRadius = contentBubbleFrame.height / 2

        self.contentBubble.frame = contentBubbleFrame
        self.contentBubble.layer.cornerRadius = contentBubbleFrameCornerRadius

        let insets = UIEdgeInsets(top: offset, left: contentBubbleFrameCornerRadius / 1.25, bottom: offset, right: contentBubbleFrameCornerRadius / 1.25)
        self.typingIndicator.frame = self.contentBubble.bounds.inset(by: insets)
    }

    // MARK: - Animation API

    func startAnimating() {
        defer { self.isAnimating = true }
        guard !self.isAnimating else { return }
        self.typingIndicator.startAnimating()
        if self.isPulseEnabled {
            self.contentBubble.layer.add(self.contentPulseAnimationLayer, forKey: AnimationKeys.pulse)
            [self.cornerBubble, self.tinyBubble].forEach { bubble in
                bubble.layer.add(self.circlePulseAnimationLayer, forKey: AnimationKeys.pulse)
            }
        }
    }

    func stopAnimating() {
        defer { self.isAnimating = false }
        guard self.isAnimating else { return }
        self.typingIndicator.stopAnimating()
        [self.contentBubble, self.cornerBubble, self.tinyBubble].forEach { bubble in
            bubble.layer.removeAnimation(forKey: AnimationKeys.pulse)
        }
    }
}
