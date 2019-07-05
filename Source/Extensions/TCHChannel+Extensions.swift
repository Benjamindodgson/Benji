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
}
