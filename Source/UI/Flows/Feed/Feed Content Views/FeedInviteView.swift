//
//  FeedInviteView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class FeedInviteView: View {

    let textView = FeedTextView()
    let button = Button()
    var reservation: Reservation?

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.button)
        self.textView.set(localizedText: "Who would you like to share Benji with?")
        self.button.set(style: .rounded(color: .blue, text: "SHARE"))
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
