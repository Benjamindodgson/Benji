//
//  FeedUnreadView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization

class FeedUnreadView: View {

    let textView = FeedTextView()
    let avatarView = AvatarView()
    let button = Button()
    var didSelect: () -> Void = {}

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.avatarView)
        self.addSubview(self.button)

        self.button.set(style: .normal(color: .blue, text: "OPEN"))
        self.button.didSelect = { [unowned self] in
            self.didSelect()
        }
    }

    func configure(with channel: TCHChannel, count: Int) {
        channel.getAuthorAsUser()
            .observeValue(with: { (user) in
                runMain {
                    self.avatarView.set(avatar: user)
                    self.textView.set(localizedText: "You have \(String(count)) unread messages in \(String(optional: channel.friendlyName))")
                    self.layoutNow()
                }
            })
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.avatarView.setSize(for: 100)
        self.avatarView.centerOnX()
        self.avatarView.top = self.height * 0.3

        self.textView.setSize(withWidth: self.width * 0.9)
        self.textView.centerOnX()
        self.textView.top = self.avatarView.bottom + Theme.contentOffset

        self.button.setSize(with: self.width)
        self.button.centerOnX()
        self.button.bottom = self.height - Theme.contentOffset
    }
}

