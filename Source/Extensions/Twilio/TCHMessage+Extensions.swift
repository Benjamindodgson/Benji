//
//  TCHMessages+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse
import TMROLocalization
import TMROFutures

extension TCHMessage: Avatar {

    var givenName: String {
        return String()
    }

    var familyName: String {
        return String()
    }

    var image: UIImage? {
        return nil
    }

    var userObjectID: String? {
        return self.author
    }
}

extension TCHMessage: Messageable {

    var updateId: String? {
        return self.attributes()?["updateId"] as? String
    }

    var id: String {
        return self.sid!
    }

    var isFromCurrentUser: Bool {
        guard let author = self.author,
            let identity = PFUser.current()?.objectId else { return false }
        return author == identity
    }

    var createdAt: Date {
        return self.timestampAsDate ?? Date()
    }

    var text: Localized {
        return String(optional: self.body)
    }

    var authorID: String {
        return String(optional: self.author)
    }

    var messageIndex: NSNumber? {
        return self.index
    }

    var attributes: [String : Any]? {
        return self.attributes()
    }

    var avatar: Avatar {
        return self
    }

    var status: MessageStatus {
        if let statusString = self.attributes()?["status"] as? String, let type = MessageStatus(rawValue: statusString) {
            return type
        }

        return .unknown
    }

    var context: MessageContext {
        if let statusString = self.attributes()?["context"] as? String, let type = MessageContext(rawValue: statusString) {
            return type
        }

        return .casual
    }

    var hasBeenConsumedBy: [String] {
        return self.attributes()?["consumers"] as? [String] ?? []
    }

    func udpateConsumers(with consumer: Avatar) {
        guard let identity = consumer.userObjectID else { return }
        var consumers = self.hasBeenConsumedBy
        consumers.append(identity)
        self.appendAttributes(with: ["consumers": consumers])
            .observeValue(with: { (_) in })
    }

    func appendAttributes(with attributes: [String: Any]) -> Future<Void> {
        let promise = Promise<Void>()
        let current: [String: Any] = self.attributes() ?? [:]
        let updated = current.merging(attributes, uniquingKeysWith: { (first, _) in first })
        self.setAttributes(updated) { (result) in
            if let error = result.error {
                promise.reject(with: error)
            } else {
                promise.resolve(with: ())
            }
        }

        return promise.withResultToast()
    }
}

extension TCHMessage {

    func getAuthorAsUser() -> Future<User> {
        let promise = Promise<User>()
        if let authorID = self.author {
            User.localThenNetworkQuery(for: authorID)
                .observeValue(with: { (user) in
                    promise.resolve(with: user)
                })
        } else {
            promise.reject(with: ClientError.message(detail: "Unable to retrieve author ID."))
        }

        return promise
    }
}
