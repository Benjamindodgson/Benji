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

extension TCHChannel: Diffable, DisplayableCellItem {
    
    var backgroundColor: Color {
        return .blue
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
            let text = attributes[ChannelKey.description.rawValue] as? String else { return String() }
        return text
    }
}

extension Future where Value == TCHChannel {

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

    func invite(personUserID: String) -> Future<TCHChannel> {

        return self.then(with: { (channel) in

            let promise = Promise<TCHChannel>()

            channel.members!.invite(byIdentity: personUserID) { (result) in
                if let error = result.error {
                    promise.reject(with: error)
                } else {
                    promise.resolve(with: channel)
                }
            }

            return promise
        })
    }

    func getAuthorAsUser() -> Future<User> {
        return self.then(with: { (channel) in
            let promise = Promise<User>()
            if let authorID = channel.createdBy {
                User.cachedQuery(for: authorID)
                    .observe { (result) in
                        switch result {
                        case .success(let user):
                            promise.resolve(with: user)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                }
            } else {
                promise.reject(with: ClientError.generic)
            }

            return promise
        })
    }

    func getUsers() -> Future<[User]> {
        return self.then { (channel) in
            let promise = Promise<[User]>()
            if let members = channel.members {
                members.members { (result, paginator) in
                    if result.isSuccessful(), let pag = paginator {
                        var identifiers: [String] = []
                        pag.items().forEach { (member) in
                            if let identifier = member.identity {
                                identifiers.append(identifier)
                            }
                        }

                        User.cachedArrayQuery(with: identifiers)
                            .observe { (result) in
                                switch result {
                                case .success(let users):
                                    promise.resolve(with: users)
                                case .failure(let error):
                                    promise.reject(with: error)
                                }
                        }
                    } else {
                        return promise.reject(with: ClientError.generic)
                    }
                }
            }

            return promise
        }
    }
}

extension TCHChannel: ImageDisplayable {

    var user: User? {
        return nil
    }

    var image: UIImage? {
        return nil 
    }

    var userObjectID: String? {
        return self.createdBy
    }

    var context: MessageContext? {
        guard let attributes = self.attributes(),
            let contextString = attributes["context"] as? String,
            let context = MessageContext(rawValue: contextString) else { return nil }
        return context
    }
}
