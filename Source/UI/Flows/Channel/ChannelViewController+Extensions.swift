//
//  ChannelViewController+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 7/2/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelViewController: KeyboardObservable, UIGestureRecognizerDelegate {

    func handleKeyboard(frame: CGRect, with animationDuration: TimeInterval, timingCurve: UIView.AnimationCurve) {

        guard !self.maintainPositionOnKeyboardFrameChanged else { return }

        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: timingCurve) {
            self.view.layoutNow()
        }

        animator.startAnimation()
        self.collectionView.scrollToEnd()
    }
    
    func handle(pan: UIPanGestureRecognizer) {
        guard let text = self.messageInputView.textView.text, !text.isEmpty else { return }

        let currentLocation = pan.location(in: self.view)
        let startingPoint: CGPoint

        if let point = self.interactiveStartingPoint {
            startingPoint = point
        } else {
            // Initial location
            startingPoint = pan.location(in: nil)
            self.interactiveStartingPoint = startingPoint
        }
        let totalOffset = self.messageInputView.height + 10
        var diff = (startingPoint.y - currentLocation.y)
        diff -= totalOffset
        var progress = diff / 100
        progress = clamp(progress, 0.0, 1.0)

        switch pan.state {
        case .possible:
            break
        case .began:
            self.previewView = PreviewMessageView()
            self.previewView?.set(backgroundColor: self.messageInputView.messageContext.color)
            self.previewView?.textView.text = self.messageInputView.textView.text
            self.previewView?.backgroundView.alpha = 0.0
            self.view.insertSubview(self.previewView!, aboveSubview: self.messageInputView)
            self.view.addSubview(self.previewView!)
            self.previewView?.frame = self.messageInputView.frame
            self.previewView?.layoutNow()
            let top = self.messageInputView.top - totalOffset

            self.previewAnimator = UIViewPropertyAnimator(duration: Theme.animationDuration,
                                                          curve: .easeInOut,
                                                          animations: nil)
            self.previewAnimator?.addAnimations {
                UIView.animateKeyframes(withDuration: 0,
                                        delay: 0,
                                        animations: {
                                            UIView.addKeyframe(withRelativeStartTime: 0,
                                                               relativeDuration: 0.3,
                                                               animations: {
                                                                self.messageInputView.textView.alpha = 0
                                                                self.previewView?.backgroundView.alpha = 1
                                            })

                                            UIView.addKeyframe(withRelativeStartTime: 0.6,
                                                               relativeDuration: 0.4,
                                                               animations: {
                                                                self.collectionView.collectionViewLayout.collectionView?.contentInset.bottom += totalOffset
                                                                self.collectionView.collectionViewLayout.invalidateLayout()
                                            })

                                            UIView.addKeyframe(withRelativeStartTime: 0,
                                                               relativeDuration: 1,
                                                               animations: {
                                                                self.previewView?.top = top
                                                                self.view.setNeedsLayout()
                                            })

                }) { (completed) in }
            }

            self.previewAnimator?.addCompletion({ (position) in
                if position == .end {
                    self.send(message: text,
                              context: self.messageInputView.messageContext,
                              attributes: ["status": MessageStatus.sent.rawValue])
                    self.previewView?.removeFromSuperview()
                }
                if position == .start {
                    self.previewView?.removeFromSuperview()
                }

                self.collectionView.collectionViewLayout.collectionView?.contentInset.bottom = 80
                self.collectionView.collectionViewLayout.invalidateLayout()
            })
            self.previewAnimator?.pauseAnimation()
        case .changed:
            if let preview = self.previewView {
                let translation = pan.translation(in: preview)
                preview.x = self.messageInputView.x + translation.x
                self.previewAnimator?.fractionComplete = (translation.y * -1) / 100
            }
        case .ended:
            self.previewAnimator?.isReversed = progress <= 0.5
            self.previewAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        case .cancelled:
            self.previewAnimator?.finishAnimation(at: .end)
        case .failed:
            self.previewAnimator?.finishAnimation(at: .end)
        @unknown default:
            break
        }
    }
}
