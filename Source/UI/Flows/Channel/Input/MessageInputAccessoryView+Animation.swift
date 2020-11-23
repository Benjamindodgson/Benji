//
//  MessageInputAccessoryView+Animation.swift
//  Benji
//
//  Created by Benji Dodgson on 6/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension MessageInputAccessoryView {

    func handle(longPress: UILongPressGestureRecognizer) {

        switch longPress.state {
        case .possible:
            break
        case .began:
            self.startAlertAnimation()
        case .changed:
            break
        case .ended, .cancelled, .failed:
            self.endAlertAnimation()
        @unknown default:
            break
        }
    }

    private func startAlertAnimation() {
        self.messageContext = .emergency
        self.alertAnimator?.stopAnimation(true)
        self.alertAnimator?.pausesOnCompletion = true
        self.selectionFeedback.impactOccurred()

        self.alertAnimator = UIViewPropertyAnimator(duration: 1.0,
                                                    curve: .linear,
                                                    animations: { [unowned self] in
            self.alertProgressView.size = CGSize(width: self.width, height: self.height)
        })

        self.alertAnimator?.startAnimation()

        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn, .repeat, .autoreverse], animations: {
            self.alertProgressView.alpha = 0
            self.selectionFeedback.impactOccurred()
        }, completion: nil)
    }

    private func endAlertAnimation() {
        if let fractionComplete = self.alertAnimator?.fractionComplete,
            fractionComplete == CGFloat(0.0) {

            self.alertAnimator?.stopAnimation(true)
            //self.showAlertConfirmation()
        } else {
            self.alertAnimator?.stopAnimation(true)
            self.messageContext = .casual
            self.alertAnimator = UIViewPropertyAnimator(duration: 0.5,
                                                        curve: .linear,
                                                        animations: { [unowned self] in
                                                            self.alertProgressView.size = CGSize(width: 0, height: self.height)
                                                            self.layer.borderColor = self.messageContext.color.color.cgColor
            })
            self.alertAnimator?.startAnimation()
        }
    }

//    private func showAlertConfirmation() {
//        guard let c = self.activeChannel, case ChannelType.channel(let channel) = c.channelType else { return }
//
//        self.alertConfirmation.frame = CGRect(x: 0,
//                                              y: 0,
//                                              width: UIScreen.main.bounds.width,
//                                              height: 60)
//
//        self.alertConfirmation.keyboardAppearance = self.expandingTextView.keyboardAppearance
//        self.expandingTextView.inputAccessoryView = self.alertConfirmation
//       // self.expandingTextView.reloadInputViews()
//
//        channel.getMembersAsUsers()
//        .observe(with: { (result) in
//            runMain {
//                switch result {
//                case .success(let users):
//                    self.alertConfirmation.setAlertMessage(for: users)
//                case .failure(_):
//                    break
//                }
//            }
//        })
//
//        self.alertProgressView.size = CGSize(width: self.width, height: self.height)
//    }
}
