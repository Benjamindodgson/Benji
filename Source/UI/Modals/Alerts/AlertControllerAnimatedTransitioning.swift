//
//  AlertControllerAnimatedTransitioning.swift
//  Benji
//
//  Created by Benji Dodgson on 3/15/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
// A custom transition for ModalAlertController that blurs the background, fades in parts of the toVC
// while simultaneously sliding up some of its views.

class AlertControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = true
    private let duration: TimeInterval = Theme.animationDuration
    private var animator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let vcKey: UITransitionContextViewControllerKey = self.isPresenting ? .to : .from

        // Make sure we have all the components we need to complete this transition
        guard let alertVC = transitionContext.viewController(forKey: vcKey)
            as? AlertViewController else {
                return
        }

        let containerView = transitionContext.containerView

        // Add blur view
        let blurView = self.addBlurViewIfNeeded(to: containerView)
        blurView.effect = self.isPresenting ? nil : UIBlurEffect(style: .dark)

        // Add view to present
        containerView.addSubview(alertVC.view)
        containerView.layoutNow()

        if self.isPresenting {
            alertVC.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            alertVC.alertView.alpha = 0
            alertVC.buttonsContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            alertVC.buttonsContainer.alpha = 0
        }

        self.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 5) {
            UIView.animateKeyframes(withDuration: 0, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5,
                                   animations: {
                                    if self.isPresenting {
                                        blurView.effect = UIBlurEffect(style: .dark)
                                    } else {
                                        alertVC.alertView.alpha = 0
                                        alertVC.alertView.top = alertVC.view.bottom
                                        alertVC.buttonsContainer.alpha = 0
                                        alertVC.view.setNeedsLayout()
                                    }
                })

                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7, animations: {
                    if self.isPresenting {
                        alertVC.alertView.alpha = 1
                        alertVC.alertView.transform = .identity
                        alertVC.buttonsContainer.transform = .identity
                        alertVC.buttonsContainer.alpha = 1 
                    } else {
                        blurView.effect = nil
                    }
                    alertVC.view.setNeedsLayout()
                })
            }, completion: nil)
        }

        self.animator?.addCompletion { (position) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        self.animator?.startAnimation()
    }

    private func addBlurViewIfNeeded(to container: UIView) -> UIVisualEffectView {
        if let blurView = container.subviews(type: UIVisualEffectView.self).first {
            return blurView
        }

        let blurView = UIVisualEffectView(frame: container.bounds)
        container.addSubview(blurView)
        return blurView
    }
}
