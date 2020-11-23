//
//  FeedMeditationView.swift
//  Benji
//
//  Created by Benji Dodgson on 4/11/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class FeedMeditationView: View {

    let textView = FeedTextView()
    let button = Button()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.button)
        self.textView.set(localizedText: "Begin a mindful minute?")
        self.button.set(style: .rounded(color: .blue, text: "Yes"))
        self.button.isEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.textView.setSize(withWidth: self.width)
        self.textView.bottom = self.centerY - 10
        self.textView.centerOnX()

        self.button.setSize(with: self.width)
        self.button.centerOnX()
        self.button.bottom = self.height - Theme.contentOffset
    }
}
