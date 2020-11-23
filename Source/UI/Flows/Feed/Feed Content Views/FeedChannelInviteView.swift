//
//  FeedChannelInviteView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization

class FeedChannelInviteView: View {

    let textView = FeedTextView()
    let avatarView = AvatarView()
    let button = Button()
    var didComplete: CompletionOptional = nil
    private var channel: TCHChannel?

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.avatarView)
        self.addSubview(self.button)

        self.button.set(style: .normal(color: .blue, text: "JOIN"))
        self.button.didSelect = { [unowned self] in
            guard let channel = self.channel else { return }
            self.join(channel: channel)
        }
    }

    func configure(with channel: TCHChannel) {
        self.channel = channel 
        channel.getAuthorAsUser()
            .observeValue(with: { (user) in
                runMain {
                    self.avatarView.set(avatar: user)
                    let text = "You have been invited to join \(String(optional: channel.friendlyName)), by \(user.fullName)"
                    self.textView.set(localizedText: text)
                    self.layoutNow()
                }
            })
    }

    private func join(channel: TCHChannel) {

        let text = LocalizedString(id: "join.channel",
                                   arguments: [channel.friendlyName!],
                                   default: "You have joined @1")
        channel.joinIfNeeded()
            .withResultToast(with: text)
            .observeValue(with: { (_) in
                self.didComplete?()
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
