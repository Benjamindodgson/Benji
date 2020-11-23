//
//  ReadAllFooterView.swift
//  Benji
//
//  Created by Benji Dodgson on 5/17/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization
import Lottie

class ReadAllFooterView: UICollectionReusableView {

    let animationView = AnimationView(name: "loading")
    private let label = SmallBoldLabel()
    var isAnimatingFinal: Bool = false
    var currentTransform: CGAffineTransform?
    private let minScale: CGFloat = 0.8

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    private func initializeViews() {
        self.set(backgroundColor: .clear)
        self.addSubview(self.label)
        self.label.alpha = 0
        self.addSubview(self.animationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
    }

    func configure(hasUnreadMessages: Bool, section: Int) {

        var text: Localized
        if hasUnreadMessages {
            text = "Read all? 🤓"
        } else {
            text = "You're up to date."
        }

        self.label.set(text: text, color: .white, alignment: .center, stringCasing: .unchanged)
        self.prepareInitialAnimation()
        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.setSize(withWidth: self.width)
        self.label.pin(.top, padding: 20)
        self.label.centerOnX()

        self.animationView.size = CGSize(width: 18, height: 18)
        self.animationView.match(.left, to: .right, of: self.label, offset: Theme.contentOffset)
        self.animationView.centerY = self.label.centerY
    }

    func setTransform(inTransform: CGAffineTransform, scaleFactor: CGFloat) {
        if self.isAnimatingFinal {
            return
        }

        self.currentTransform = inTransform
        if scaleFactor >= self.minScale {
            self.label.transform = CGAffineTransform.init(scaleX: scaleFactor, y: scaleFactor)
        }
        self.label.alpha = scaleFactor
    }

    //reset the animation
    func prepareInitialAnimation() {
        self.isAnimatingFinal = false
        self.label.alpha = 0
        self.label.transform = CGAffineTransform.init(scaleX: self.minScale, y: self.minScale)
    }

    func start(showLoading: Bool) {
        self.isAnimatingFinal = true
        if !self.animationView.isAnimationPlaying, showLoading {
            self.animationView.play()
        }
    }

    func stop() {
        self.isAnimatingFinal = false
        self.animationView.stop()
        self.prepareInitialAnimation()
    }

    //final animation to display loading
    func animateFinal() {
        if self.isAnimatingFinal {
            return
        }
        self.isAnimatingFinal = true
        UIView.animate(withDuration: Theme.animationDuration) {
            self.label.alpha = 1
            self.label.transform = .identity
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.label.text = nil
    }
}
