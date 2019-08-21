//
//  ChannelCollectionViewController+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 7/5/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

extension ChannelCollectionViewController {

    func loadMessages(for type: ChannelType) {

        switch type {
        case .system( _ ):
            self.loadTestMessages()
        case .channel(let channel):
            self.loadChannelMessages(with: channel)
        }
    }

    private func loadChannelMessages(with channel: TCHChannel) {
        self.channelDataSource.reset()
        ChannelManager.shared.selectedChannel = channel
        ChannelManager.shared.getAllMessages(for: channel) { [unowned self] (sections) in
            self.channelDataSource.set(newSections: sections)
            delay(0.5, { [weak self] in
                guard let `self` = self else { return }
                self.collectionView.scrollToBottom()
            })
        }
    }

    private func loadTestMessages() {
        self.channelDataSource.set(newSections: Lorem.systemSections())
        delay(0.5) { [weak self] in
            guard let `self` = self else { return }
            self.collectionView.scrollToBottom()
        }
    }

    func subscribeToClient() {
        ChannelManager.shared.clientSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self, let clientUpdate = update else { return }

            switch clientUpdate {
            case .started, .channelsListCompleted:
                self.loadingView.startAnimating()
            case .completed:
                self.loadingView.stopAnimating()
            case .failed:
                self.loadingView.stopAnimating()
            @unknown default:
                break
            }
        }
        .start()
    }

    func subscribeToUpdates() {

        ChannelManager.shared.messageUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let channelUpdate = update, channelUpdate.channel == ChannelManager.shared.selectedChannel else { return }

            switch channelUpdate.status {
            case .added:
                self.channelDataSource.append(item: .message(channelUpdate.message))
                runMain {
                    self.collectionView.scrollToBottom()
                }
            // Add check here for last message not from user and its attributes to find quick messsages
            case .changed:
                self.channelDataSource.update(item: .message(channelUpdate.message))
            case .deleted:
                self.channelDataSource.delete(item: .message(channelUpdate.message))
            case .toastReceived:
                break
        }
        }.start()

        ChannelManager.shared.memberUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let memberUpdate = update, memberUpdate.channel == ChannelManager.shared.selectedChannel else { return }

            switch memberUpdate.status {
            case .joined:
                break
            case .left:
                break
            case .changed:
                self.loadChannelMessages(with: memberUpdate.channel)
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
                self.loadChannelMessages(with: channelsUpdate.channel)
            @unknown default:
                break
            }
            }.start()
    }
}
