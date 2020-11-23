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
        return self.attributes()?.dictionary?["updateId"] as? String
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
        return self.dateCreatedAsDate ?? Date()
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
        return self.attributes()?.dictionary as? [String: Any]
    }

    var avatar: Avatar {
        return self
    }

    var status: MessageStatus {
        return .delivered
    }

    var kind: MessageKind {
        switch self.messageType {
        case .text:
            return .text(String(optional: self.body))
        case .media:
            guard let type = self.mediaType, let mediaType = MediaType(rawValue: type) else {
                return .text(String(optional: self.body))
            }

            switch mediaType {
            case .photo:
                return .photo(EmptyMediaItem(mediaType: mediaType))
            case .video:
                fatalError()
            }
        default:
            return .text(String(optional: self.body))
        }
    }

    var context: MessageContext {
        if let statusString = self.attributes()?.dictionary?["context"] as? String, let type = MessageContext(rawValue: statusString) {
            return type
        }

        return .casual
    }

    var hasBeenConsumedBy: [String] {
        return self.attributes()?.dictionary?["consumers"] as? [String] ?? []
    }

    @discardableResult
    func udpateConsumers(with consumer: Avatar) -> Future<Void> {
        let promise = Promise<Void>()

        if let identity = consumer.userObjectID {
            var consumers = self.hasBeenConsumedBy
            consumers.append(identity)
            self.appendAttributes(with: ["consumers": consumers])
                .observeValue(with: { (_) in
                    self.getAuthorAsUser()
                        .observe(with: { (result) in
                            switch result {
                            case .success(let author):
                                ToastScheduler.shared.schedule(toastType: .messageConsumed(self, author))
                                promise.resolve(with: ())
                            case .failure(let error):
                                promise.reject(with: error)
                            }
                        })
                    })
        } else {
            promise.reject(with: ClientError.generic)
        }

        return promise
    }

    func appendAttributes(with attributes: [String: Any]) -> Future<Void> {
        let promise = Promise<Void>()
        let current: [String: Any] = self.attributes()?.dictionary as? [String: Any] ?? [:]
        let updated = current.merging(attributes, uniquingKeysWith: { (first, _) in first })

        if let newAttributes = TCHJsonAttributes.init(dictionary: updated) {
            self.setAttributes(newAttributes) { (result) in
                if let error = result.error {
                    promise.reject(with: error)
                } else {
                    promise.resolve(with: ())
                }
            }
        } else {
            promise.reject(with: ClientError.generic)
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
