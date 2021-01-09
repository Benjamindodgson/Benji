//
//  FeedNewChannelView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/20/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization
import Combine

class FeedNewChannelView: View {

    let textView = FeedTextView()
    let avatarView = AvatarView()
    let button = Button()
    var didSelect: () -> Void = {}
    private var cancellables = Set<AnyCancellable>()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.avatarView)
        self.addSubview(self.button)

        self.button.set(style: .normal(color: .blue, text: "OPEN"))
        self.button.didSelect { [unowned self] in
            self.didSelect()
        }
    }

    func configure(with channel: DisplayableChannel) {
        guard case ChannelType.channel(let tchChannel) = channel.channelType else { return }
        tchChannel.getAuthorAsUser()
            .mainSink(receiveResult: { (user, error) in
                guard let u = user else { return }
                self.avatarView.set(avatar: u)
                let message = LocalizedString(id: "", arguments: [u.givenName], default: "Congrats! 🎉 You can now chat with @(name)!")
                self.textView.set(localizedText: message)
                self.layoutNow()
            }).store(in: &self.cancellables)
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
