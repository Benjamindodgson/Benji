//
//  ChannelDetailBar.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse
import TMROLocalization

protocol ChannelDetailBarDelegate: class {
    func channelDetailBarDidTapMenu(_ view: ChannelDetailBar)
}

class ChannelDetailBar: View {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private(set) var titleLabel = RegularBoldLabel()
    private let titleButton = Button()
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)
    private(set) var stackedAvatarView = StackedAvatarView()
    let channelType: ChannelType

    unowned let delegate: ChannelDetailBarDelegate

    init(with channelType: ChannelType, delegate: ChannelDetailBarDelegate) {
        self.delegate = delegate
        self.channelType = channelType
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.blurView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.titleButton)
        self.addSubview(self.stackedAvatarView)
        
        self.titleButton.onTap { [unowned self] (tap) in
            self.delegate.channelDetailBarDidTapMenu(self)
        }

        switch self.channelType {
        case .system(let channel):
            self.setLayout(for: channel)
        case .channel(let channel):
            self.setLayout(for: channel)
            channel.getMembersAsUsers()
                .observe { (result) in
                switch result {
                case .success(let users):
                    let notMeUsers = users.filter { (user) -> Bool in
                        return user.objectId != User.current()?.objectId
                    }
                    self.stackedAvatarView.set(items: notMeUsers)
                case .failure(let error):
                    print(error)
                }
            }
        }

        self.subscribeToUpdates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.blurView.frame = self.bounds

        let titleWidth = self.width - 44
        self.titleLabel.setSize(withWidth: titleWidth)
        self.titleLabel.left = 16
        self.titleLabel.centerOnY()

        self.titleButton.size = CGSize(width: self.titleLabel.width, height: self.height)
        self.titleButton.left = self.titleLabel.left
        self.titleButton.centerOnY()

        self.stackedAvatarView.height = 40
        self.stackedAvatarView.right = self.width - 16
        self.stackedAvatarView.centerOnY()
    }

    func setLayout(for system: SystemChannel) {
        self.set(text: system.displayName)
    }

    func setLayout(for channel: TCHChannel) {
        self.updateFriendlyName(for: channel)
    }

    private func updateFriendlyName(for channel: TCHChannel) {
        if let name = channel.friendlyName {
            self.set(text: name)
        }
    }

    private func set(text: Localized) {
        self.titleLabel.set(text: text)
        self.layoutNow()
    }

    private func subscribeToUpdates() {

        ChannelManager.shared.channelSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let channelsUpdate = update,
                channelsUpdate.channel == ChannelManager.shared.activeChannel.value else { return }

            switch channelsUpdate.status {
            case .all:
                self.updateFriendlyName(for: channelsUpdate.channel)
            default:
                break
            }
        }.start()
    }
}
