//
//  MessageInputView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageInputView: View, UIGestureRecognizerDelegate {

    let minHeight: CGFloat = 52

    let contextButton = ContextButton()
    let textView = InputTextView()
    let overlayButton = UIButton()
    let alertProgressView = UIView()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .backgroundWithAlpha)

        self.addSubview(self.contextButton)
        self.addSubview(self.alertProgressView)
        self.alertProgressView.set(backgroundColor: .red)
        self.alertProgressView.size = .zero 
        self.addSubview(self.textView)
        self.textView.minHeight = self.minHeight
        self.addSubview(self.overlayButton)

        self.overlayButton.onTap { [unowned self] (tap) in
            if !self.textView.isFirstResponder {
                self.textView.becomeFirstResponder()
            }
        }

        self.layer.masksToBounds = true
        self.layer.borderColor = Color.lightPurple.color.cgColor
        self.layer.borderWidth = Theme.borderWidth
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.contextButton.size = CGSize(width: 0, height: 0)
        self.contextButton.left = 0
        self.contextButton.bottom = self.height

        let textViewWidth = self.width - self.contextButton.right - 20
        self.textView.size = CGSize(width: textViewWidth, height: self.textView.currentHeight)
        self.textView.left = self.contextButton.right + 10
        self.textView.top = 0

        self.layer.cornerRadius = self.minHeight * 0.5

        self.overlayButton.frame = self.bounds
    }
}
