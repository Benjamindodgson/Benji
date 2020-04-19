//
//  ChannelViewController+Updates.swift
//  Benji
//
//  Created by Benji Dodgson on 11/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelViewController {

    func loadMessages(for channelType: ChannelType) {
        self.collectionViewManager.reset()

        switch channelType {
        case .system(let channel):
            self.loadSystem(channel: channel)
        case .channel(_):
            MessageSupplier.shared.getLastMessages()
        }
    }

    private func loadSystem(channel: SystemChannel) {
        let sections = MessageSupplier.shared.mapMessagesToSections(for: channel.messages, in: .system(channel))
        self.collectionViewManager.set(newSections: sections) { [weak self] in
            guard let `self` = self else { return }
            self.collectionView.scrollToEnd()
        }
    }

    func subscribeToClient() {
        ChannelManager.shared.clientSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self, let clientUpdate = update else { return }

            switch clientUpdate {
            case .started, .channelsListCompleted:
                break
            case .completed:
                self.subscribeToUpdates()
            case .failed:
                break
            @unknown default:
                break
            }
        }
        .start()
    }

    private func subscribeToUpdates() {

        ChannelManager.shared.messageUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let channelUpdate = update, ChannelSupplier.shared.isChannelEqualToActiveChannel(channel: channelUpdate.channel) else { return }

            switch channelUpdate.status {
            case .added:
                if self.collectionView.isTypingIndicatorHidden {
                    self.collectionViewManager.updateItem(with: channelUpdate.message) {
                        self.collectionView.scrollToEnd()
                    }
                } else {
                    self.collectionViewManager.setTypingIndicatorViewHidden(true, performUpdates: { [weak self] in
                        guard let `self` = self else { return }
                        self.collectionViewManager.updateItem(with: channelUpdate.message,
                                                              replaceTypingIndicator: true,
                                                              completion: nil)
                    })
                }
            case .changed:
                self.collectionViewManager.updateItem(with: channelUpdate.message)
            case .deleted:
                self.collectionViewManager.delete(item: channelUpdate.message)
            case .toastReceived:
                break
            }
            }.start()

        ChannelManager.shared.memberUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let memberUpdate = update, ChannelSupplier.shared.isChannelEqualToActiveChannel(channel: memberUpdate.channel) else { return }

            switch memberUpdate.status {
            case .joined, .left:
                memberUpdate.channel.getMembersCount { [unowned self] (result, count) in
                    self.collectionViewManager.numberOfMembers = Int(count)
                }
            case .changed:
                break
                //self.loadMessages()
            case .typingEnded:
                if let memberID = memberUpdate.member.identity, memberID != User.current()?.objectId {
                    self.collectionViewManager.userTyping = nil
                    self.collectionViewManager.setTypingIndicatorViewHidden(true)
                }
            case .typingStarted:
                if let memberID = memberUpdate.member.identity, memberID != User.current()?.objectId {
                    memberUpdate.member.getMemberAsUser()
                        .observeValue { [unowned self] (user) in
                            runMain {
                                self.collectionViewManager.userTyping = user
                                self.collectionViewManager.setTypingIndicatorViewHidden(false, performUpdates: nil)
                            }
                    }
                }
            }
        }.start()

        ChannelManager.shared.channelSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let syncUpdate = update else { return }

            switch syncUpdate.status {
                case .none, .identifier, .metadata, .failed:
                    break
                case .all:
                    break
                    //self.loadMessages()
                @unknown default:
                    break
            }

        }.start()
    }
}
