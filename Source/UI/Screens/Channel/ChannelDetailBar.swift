//
//  ChannelDetailBar.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelDetailBar: View {

    private(set) var titleLabel = Display2Label()
    private(set) var avatarView = AvatarView()

    override func initialize() {
        super.initialize()

        self.addSubview(self.titleLabel)
        self.addSubview(self.avatarView)

        self.subscribeToUpdates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.avatarView.size = CGSize(width: 32, height: 32)
        self.avatarView.right = self.width - 18
        self.avatarView.centerOnY()

        let titleWidth = self.width - 68
        self.titleLabel.setSize(withWidth: titleWidth)
        self.titleLabel.left = 18
        self.titleLabel.centerOnY()
    }

    func set(avatar: Avatar) {
        self.avatarView.set(avatar: avatar)
        self.set(text: avatar.firstName)
    }

    func set(text: Localized) {
        self.titleLabel.set(text: text)
        self.layoutNow()
    }

    private func subscribeToUpdates() {
        ChannelManager.shared.memberUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let memberUpdate = update, memberUpdate.channel == ChannelManager.shared.selectedChannel else { return }

            //Update collection of Avatars 
            switch memberUpdate.status {
            case .joined:
                break
            case .left:
                break
            case .changed:
                break
               // self.loadChannelMessages(with: memberUpdate.channel)
            case .typingEnded:
                break
                //                if let memberID = memberUpdate.member.identity, memberID != User.me?.id {
                //                    self.hideStatusUpdate()
            //                }
            case .typingStarted:
                break
                //                if let memberID = memberUpdate.member.identity, memberID != User.me?.id {
                //                    self.showTyping(for: memberUpdate.member)
                //                }
            }
            }.start()

        ChannelManager.shared.channelSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let channelsUpdate = update, channelsUpdate.channel == ChannelManager.shared.selectedChannel
                else { return }

            switch channelsUpdate.status {
            case .none, .identifier, .metadata, .failed:
                break
            case .all:
                if let name = channelsUpdate.channel.friendlyName {
                    self.set(text: name)
                }

                channelsUpdate.channel.getAuthorAsUser().observe(with: { (result) in
                    switch result {
                    case .success(let user):
                        self.avatarView.set(avatar: user)
                    case .failure(let error):
                        print(error)
                    }
                })
                
            @unknown default:
                break
            }
            }.start()
    }
}
