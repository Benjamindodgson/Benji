//
//  TCHChannel+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse
import TMROFutures
import ReactiveSwift

extension TCHChannel: Diffable, ManageableCellItem {

    var id: String {
        return self.sid!
    }
    
    var backgroundColor: Color {
        return .blue
    }

    var isOwnedByMe: Bool {
        guard let currentUser = User.current() else { return false }
        return self.createdBy == currentUser.objectId
    }

    var context: ConversationContext? {
        guard let dict = self.attributes()?.dictionary,
            let contextString = dict[ChannelKey.context.rawValue] as? String,
            let context = ConversationContext(rawValue: contextString) else { return nil }
        return context
    }

    func diffIdentifier() -> NSObjectProtocol {
        return String(optional: self.sid) as NSObjectProtocol
    }

    func joinIfNeeded() -> Future<TCHChannel> {
        let promise = Promise<TCHChannel>(value: self)
        return promise.joinIfNeeded().then(with: { (channel) in
            return Promise<TCHChannel>(value: channel)
        }).then(with: { (channel) in
            return Promise<TCHChannel>(value: channel)
        })
    }

    func getNonMeMembers() -> Future<[TCHMember]> {

        let promise = Promise<[TCHMember]>()
        if let members = self.members?.membersList() {
            var nonMeMembers: [TCHMember] = []
            members.forEach { (member) in
                if member.identity != User.current()?.objectId {
                    nonMeMembers.append(member)
                }
            }
        } else {
            promise.reject(with: ClientError.message(detail: "There was a problem fetching other members."))
        }

        return promise.withResultToast()
    }

    func getAuthorAsUser() -> Future<User> {
        let promise = Promise<TCHChannel>(value: self)
        return promise.getAuthorAsUser()
    }

    func getMembersAsUsers() -> Future<[User]> {
        let promise = Promise<TCHChannel>(value: self)
        return promise.getUsers()
    }

    var channelDescription: String {
        guard let attributes = self.attributes(),
            let text = attributes.dictionary?[ChannelKey.description.rawValue] as? String else { return String() }
        return text
    }

    func getUnconsumedCount() -> SignalProducer<FeedType, Error> {
        var totalUnread: Int = 0

        return SignalProducer { [weak self] observer, lifetime in
            guard let `self` = self else { return }

            if let messagesObject = self.messages {
                self.getMessagesCount { (result, count) in
                    if result.isSuccessful() {
                        messagesObject.getLastWithCount(count) { (messageResult, messages) in

                            if messageResult.isSuccessful(), let msgs = messages {
                                msgs.forEach { (message) in
                                    if !message.isFromCurrentUser, !message.isConsumed, message.canBeConsumed {
                                        totalUnread += 1
                                    }
                                }
                                observer.send(value: .unreadMessages(self, totalUnread))
                                observer.sendCompleted()
                            } else {
                                observer.send(error: ClientError.message(detail: "Unable to get messages."))
                            }
                        }
                    } else {
                        observer.send(error: ClientError.message(detail: "Failed to get message count."))
                    }
                }
            } else {
                observer.send(error: ClientError.message(detail: "There were no messages."))
            }
        }
    }

    func invite(users: [User]) -> Future<TCHChannel> {
        var promises: [Future<Void>] = []

        users.forEach { (user) in
            promises.append(self.invite(user: user))
        }

        return waitForAll(futures: promises)
            .transform { (channels) -> TCHChannel in
                return self
        }
    }

    func invite(user: User) -> Future<Void> {

        let promise = Promise<Void>()
        let identity = String(optional: user.objectId)
        if let members = self.members {
            members.invite(byIdentity: identity) { (result) in
                if let error = result.error {
                    promise.reject(with: error)
                } else {
                    promise.resolve(with: ())
                }
            }
        } else {
             promise.resolve(with: ())
        }

        return promise
    }
}

extension Future where Value == TCHChannel {

    func invite(users: [User]) -> Future<TCHChannel> {
        return self.then { (channel) -> Future<TCHChannel> in
            return channel.invite(users: users)
        }
    }

    func joinIfNeeded() -> Future<TCHChannel> {

        return self.then(with: { (channel) in

            // There's no need to join the channel if the current user is already a member
            guard let id = PFUser.current()?.objectId, channel.member(withIdentity: id) == nil else {
                return Promise<TCHChannel>(value: channel)
            }

            let promise = Promise<TCHChannel>()
            channel.join(completion: { (result) in
                if let error = result.error {
                    promise.reject(with: error)
                } else {
                     promise.resolve(with: channel)
                }
            })

            return promise
        })
    }

    func getAuthorAsUser() -> Future<User> {
        return self.then(with: { (channel) in
            let promise = Promise<User>()
            if let authorID = channel.createdBy {
                User.localThenNetworkQuery(for: authorID)
                    .observeValue(with: { (user) in
                        promise.resolve(with: user)
                    })
            } else {
                promise.reject(with: ClientError.message(detail: "This channel has no author ID."))
            }

            return promise
        })
    }

    func getUsers() -> Future<[User]> {
        return self.then { (channel) in
            let promise = Promise<[User]>()
            if let members = channel.members?.membersList() {

                var identifiers: [String] = []
                members.forEach { (member) in
                    if let identifier = member.identity {
                        identifiers.append(identifier)
                    }
                }

                User.localThenNetworkArrayQuery(where: identifiers,
                                            isEqual: true,
                                            container: .channel(identifier: channel.sid!))
                .observeValue(with: { (users) in
                    promise.resolve(with: users)
                })
            }

            return promise
        }
    }
}

extension TCHChannel: Avatar {

    var givenName: String {
        return String()
    }

    var familyName: String {
        return String()
    }

    var user: User? {
        return nil
    }

    var image: UIImage? {
        return nil
    }
    
    var userObjectID: String? {
        return self.createdBy
    }
}

extension TCHChannel: Comparable {
    public static func < (lhs: TCHChannel, rhs: TCHChannel) -> Bool {
        guard let lhsDate = lhs.dateUpdatedAsDate, let rhsDate = rhs.dateUpdatedAsDate else { return false }
        return lhsDate > rhsDate
    }
}
