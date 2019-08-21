//
//  MessageInputView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageInputView: View {

    let minHeight: CGFloat = 52

    let contextButton = ContextButton()
    let textView = InputTextView()

    override func initialize() {
        super.initialize()

        self.set(backgroundColor: .backgroundWithAlpha)

        self.addSubview(self.contextButton)
        self.addSubview(self.textView)
        self.textView.minHeight = self.minHeight

        self.layer.masksToBounds = true
        self.layer.borderColor = Color.lightPurple.color.cgColor
        self.layer.borderWidth = Theme.borderWidth
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.contextButton.size = CGSize(width: self.minHeight, height: self.minHeight)
        self.contextButton.left = 0
        self.contextButton.bottom = self.height

        let textViewWidth = self.width - self.contextButton.right
        self.textView.size = CGSize(width: textViewWidth, height: self.textView.currentHeight)
        self.textView.left = self.contextButton.right
        self.textView.top = 0

        self.layer.cornerRadius = self.minHeight * 0.5
    }
}
