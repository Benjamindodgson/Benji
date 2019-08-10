//
//  ToastView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum ToastPosition {
    case top, bottom
}

enum ToastState {
    case hidden, present, left, expanded, alphaIn, dismiss, gone
}

class ToastView: UIView {

    @IBOutlet weak var titleLabel: XSmallLabel!
    @IBOutlet weak var displayableImageView: DisplayableImageView!
    @IBOutlet weak var buttonContainer: UIView!

    var didDismiss: () -> Void = {}
    var didTap: () -> Void = {}

    var toast: Toast?

    let revealAnimator = UIViewPropertyAnimator(duration: 0.35,
                                                dampingRatio: 0.6,
                                                animations: nil)

    let leftAnimator = UIViewPropertyAnimator(duration: 0.35,
                                              dampingRatio: 0.9,
                                              animations: nil)

    let expandAnimator = UIViewPropertyAnimator(duration: 0.35,
                                                dampingRatio: 0.9,
                                                animations: nil)

    let dismissAnimator = UIViewPropertyAnimator(duration: 0.35,
                                                 dampingRatio: 0.6,
                                                 animations: nil)

    private var panStart: CGPoint?
    private var startY: CGFloat?

    var screenOffset: CGFloat = 50
    var presentationDuration: TimeInterval = 6.0
    //Used to present the toast from the top OR bottom of the screen
    private let position: ToastPosition = .top

    private var toastState = ToastState.hidden {
        didSet {
            if self.toastState != oldValue {
                self.updateFor(state: self.toastState)
            }
        }
    }

    private var title: Localized? {
        didSet {
            guard let text = self.title else { return }
            self.titleLabel.set(text: text,
                                color: .white,
                                lineBreakMode: .byTruncatingTail)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initializeViews()
    }

    private func initializeViews() {

        guard let superview = UIWindow.topWindow() else { return }
        superview.addSubview(self)

        self.set(backgroundColor: .purple)

        self.isUserInteractionEnabled = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 30

        self.titleLabel.alpha = 0
        self.buttonContainer.alpha = 0

        self.addShadow(withOffset: 5)
        self.updateFor(state: self.toastState)

        if self.position == .top {
            self.screenOffset = superview.safeAreaInsets.top
        } else {
            self.screenOffset = superview.safeAreaInsets.bottom
        }

        self.setNeedsLayout()
    }

    func configure(toast: Toast) {
        self.toast = toast
        self.title = toast.title
        self.buttonContainer.addSubview(toast.button)

        toast.button.onTap { (tap) in
            //Add any repsone to the button tap here
            self.didTap()
            toast.button.didSelect?()
            self.dismiss()
        }

        self.displayableImageView.displayable = toast.displayable
    }

    func reveal() {
        self.revealAnimator.stopAnimation(true)
        self.revealAnimator.addAnimations { [unowned self] in
            self.toastState = .present
        }

        self.revealAnimator.addCompletion({ [unowned self] (position) in
            if position == .end {
                self.moveLeft()
            }
        })
        self.revealAnimator.startAnimation(afterDelay: 0.5)
    }

    private func moveLeft() {
        self.leftAnimator.stopAnimation(true)
        self.leftAnimator.addAnimations { [unowned self] in
            self.toastState = .left
        }

        self.leftAnimator.addCompletion({ [unowned self] (position) in
            if position == .end {
                self.expand()
            }
        })
        self.leftAnimator.startAnimation()
    }

    private func expand() {
        self.expandAnimator.stopAnimation(true)
        self.expandAnimator.addAnimations { [unowned self] in
            self.toastState = .expanded
        }

        self.expandAnimator.addAnimations({ [unowned self] in
            self.toastState = .alphaIn
            }, delayFactor: 0.1)

        self.expandAnimator.addCompletion({ [unowned self] (position) in
            if position == .end {
                self.addPan()
                delay(self.presentationDuration) {
                    if self.toastState != .gone {
                        self.dismiss()
                    }
                }
            }
        })

        self.expandAnimator.startAnimation(afterDelay: 0.2)
    }

    private func addPan() {
        let panRecognizer = UIPanGestureRecognizer { [unowned self] panRecognizer in
            self.handle(panRecognizer: panRecognizer)
        }
        self.addGestureRecognizer(panRecognizer)
    }

    func dismiss() {

        self.revealAnimator.stopAnimation(true)
        self.expandAnimator.stopAnimation(true)
        self.leftAnimator.stopAnimation(true)

        self.dismissAnimator.addAnimations{ [unowned self] in
            self.toastState = .dismiss
        }

        self.dismissAnimator.addCompletion({ [unowned self] (position) in
            if position == .end {
                self.toastState = .gone
                self.didDismiss()
            }
        })
        self.dismissAnimator.startAnimation()
    }

    private func updateFor(state: ToastState) {
        guard let superView = UIWindow.topWindow() else { return }
        switch state {
        case .hidden:
            if self.position == .top {
                self.bottom = superView.top - self.screenOffset - superView.safeAreaInsets.top
            } else {
                self.top = superView.bottom + self.screenOffset + superView.safeAreaInsets.bottom
            }
            self.width = 60
            self.height = 60
            self.centerOnX()
        case .present:
            if self.position == .top {
                self.top = superView.top + self.screenOffset
            } else {
                self.bottom = superView.bottom - self.screenOffset
            }
        case .left:
            if UIScreen.main.isSmallerThan(screenSize: .tablet) {
                self.left = superView.width * 0.025
            } else {
                self.left = superView.width * 0.175
            }
        case .expanded:
            if UIScreen.main.isSmallerThan(screenSize: .tablet) {
                self.width = superView.width * 0.95
            } else {
                self.width = superView.width * Theme.iPadPortraitWidthRatio
            }
        case .alphaIn:
            self.titleLabel.alpha = 1
            self.buttonContainer.alpha = 1
        case .dismiss, .gone:
            if self.position == .top {
                self.bottom = superView.top + 10
            } else {
                self.top = superView.bottom - 10
            }
        }
    }

    private func handle(panRecognizer: UIPanGestureRecognizer) {
        guard let superview = UIWindow.topWindow() else { return }

        switch panRecognizer.state {
        case .began:
            self.initializePanIfNeeded(panRecognizer: panRecognizer)
        case .changed:
            self.initializePanIfNeeded(panRecognizer: panRecognizer)

            if let panStart = self.panStart, let startY = self.startY {
                let delta = panStart.y + panRecognizer.translation(in: superview).y
                self.centerY = (startY...CGFloat.greatestFiniteMagnitude).clamp(delta + startY)
            }
        case .ended, .cancelled, .failed:
            // Ensure we don't respond the end of an untracked pan gesture
            let offset = superview.height - self.screenOffset * 0.5
            if self.top <= offset {
                self.dismiss()
            }
        case .possible:
            break
        @unknown default:
            break
        }
    }

    private func initializePanIfNeeded(panRecognizer: UIPanGestureRecognizer) {
        if self.panStart == nil, let superview = UIWindow.topWindow() {
            self.startY = self.centerY
            self.panStart = panRecognizer.translation(in: superview)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.height = 60

        self.displayableImageView.size = CGSize(width: 50, height: 50)
        self.displayableImageView.left = 5
        self.displayableImageView.centerOnY()

        let maxTitleWidth = self.buttonContainer.left - (self.displayableImageView.right + 12)
        let titleSize = self.titleLabel.getSize(withWidth: maxTitleWidth)
        self.titleLabel.width = titleSize.width
        self.titleLabel.left = self.displayableImageView.right + 5
        self.titleLabel.top = self.displayableImageView.top
        self.titleLabel.height = self.displayableImageView.height
        self.titleLabel.centerOnY()

        self.toast?.button.frame = self.buttonContainer.bounds
    }
}
