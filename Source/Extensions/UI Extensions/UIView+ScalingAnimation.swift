//
//  UIView+ScalingAnimation.swift
//  Benji
//
//  Created by Benji Dodgson on 12/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIView {

    func scaleDown(xScale: CGFloat = 0.95, yScale: CGFloat = 0.9) {

        let propertyAnimator = UIViewPropertyAnimator(duration: 0.6,
                                                      dampingRatio: 0.6) {
                                                        self.transform = CGAffineTransform(scaleX: xScale, y: yScale)
        }
        propertyAnimator.startAnimation()
    }

    func scaleUp() {
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.6,
                                                      dampingRatio: 0.6) {
                                                        self.transform = .identity
        }
        propertyAnimator.startAnimation()
    }
}
