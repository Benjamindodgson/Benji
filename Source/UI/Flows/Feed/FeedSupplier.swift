//
//  FeedSupplier.swift
//  Benji
//
//  Created by Benji Dodgson on 11/16/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROFutures
import ReactiveSwift
import Parse

class FeedSupplier {

    static let shared = FeedSupplier()

    private(set) var items: [FeedType] = []

    func getFirstItems() -> Future<[FeedType]> {
        var promises: [Future<Void>] = []
        self.items.append(.rountine)
        promises.append(self.getNewChannels())

        return waitForAll(futures: promises)
            .transform { (_) in
                return self.items.sorted()
        }
    }

    func getItems() -> Future<[FeedType]> {

        self.items.append(.meditation)

        ChannelSupplier.shared.allInvitedChannels.forEach { (channel) in
            switch channel.channelType {
            case .channel(let tchChannel):
                self.items.append(.channelInvite(tchChannel))
            default:
                break
            }
        }

        var promises: [Future<Void>] = []
        promises.append(self.getInviteAsk())
        promises.append(self.getNotificationPermissions())
        promises.append(self.getUnreadMessages())
        promises.append(self.getConnections())

        return waitForAll(futures: promises)
            .transform { (_) in
                return self.items.sorted()
        }
    }

    private func getInviteAsk() -> Future<Void> {
        let promise = Promise<Void>()
        Reservation.getFirstUnclaimed(for: User.current()!)
            .observe { (result) in
                switch result {
                case .success(let reservation):
                    self.items.append(.inviteAsk(reservation))
                    promise.resolve(with: ())
                case .failure(let error):
                    promise.reject(with: error)
                }
        }

        return promise
    }

    private func getNotificationPermissions() -> Future<Void>  {
        let promise = Promise<Void>()
        UserNotificationManager.shared.getNotificationSettings()
            .observeValue { (settings) in
                if settings.authorizationStatus != .authorized {
                    self.items.append(.notificationPermissions)
                }
                promise.resolve(with: ())
        }

        return promise
    }

    private func getUnreadMessages() -> Future<Void> {
        let promise = Promise<Void>()
        var allProducers: SignalProducer<[FeedType], Error>

        var channelProducers: [SignalProducer<FeedType, Error>] = []
        for channel in ChannelSupplier.shared.allJoinedChannels {
            switch channel.channelType {
            case .channel(let tchChannel):
                channelProducers.append(tchChannel.getUnconsumedCount())
            default:
                break
            }
        }

        if channelProducers.count == 0 {
            self.items.append(.timeSaved(0))
        }

        allProducers = SignalProducer.combineLatest(channelProducers)

        var disposable: Disposable?
        disposable = allProducers
            .on(value: { (channelItems) in
                var totalCount: Int = 0
                let items = channelItems.filter { (feedType) -> Bool in
                    switch feedType {
                    case .unreadMessages(_,let count):
                        totalCount += count
                        return count > 0
                    default:
                        return false
                    }
                }
                self.items.append(.timeSaved(totalCount))
                self.items.append(contentsOf: items)
            })
            .on(failed: { (error) in
                disposable?.dispose()
            }, completed: {
                disposable?.dispose()
                promise.resolve(with: ())
            }).start()

        return promise
    }

    private func getConnections() -> Future<Void> {
        let promise = Promise<Void>()
        GetAllConnections(direction: .incoming).makeRequest()
            .observe { (result) in
                switch result {
                case .success(let connections):
                    connections.forEach { (connection) in
                        if connection.status == .invited {
                            self.items.append(.connectionRequest(connection))
                        }
                    }
                    promise.resolve(with: ())
                case .failure(let error):
                    promise.reject(with: error)
                }
        }

        return promise
    }

    private func getNewChannels() -> Future<Void> {
        let promise = Promise<Void>()
        GetAllConnections(direction: .incoming).makeRequest()
            .observe { (result) in
                switch result {
                case .success(let connections):
                    connections.forEach { (connection) in
                        if connection.status == .accepted,
                            let channelId = connection.channelId,
                            let channel = ChannelSupplier.shared.getChannel(withSID: channelId) {
                            self.items.append(.newChannel(channel))
                        }
                    }
                    promise.resolve(with: ())
                case .failure(let error):
                    promise.reject(with: error)
                }
        }

        return promise
    }
}
