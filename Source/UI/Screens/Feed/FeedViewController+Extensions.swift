//
//  FeedViewController+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension FeedViewController {

    func subscribeToUpdates() {


        ChannelManager.shared.clientSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self, let clientUpdate = update else { return }

            switch clientUpdate {
            case .started, .channelsListCompleted:
                break
            case .completed:
                self.addItems()
            case .failed:
                break
            @unknown default:
                break
            }
            }
            .start()
    }

    func addItems() {

        var items: [FeedType] = []

        ChannelManager.shared.channelTypes.forEach { (type) in
            switch type {
            case .channel(let channel):
                if channel.status == .invited {
                    items.append(.channelInvite(channel))
                }
            default:
                break
            }
        }

        self.manager.set(items: items)
    }
}
