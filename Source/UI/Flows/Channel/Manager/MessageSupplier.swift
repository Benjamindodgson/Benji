//
//  MessageSupplier.swift
//  Benji
//
//  Created by Benji Dodgson on 11/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROFutures

class MessageSupplier {

    static let shared = MessageSupplier()

    /// To paginate and keep messages sorted we need to maintain a list
    private(set) var allMessages: [Messageable] = []
    private(set) var sections: [ChannelSectionable] = []
    private var messagesObject: TCHMessages?

    var unreadMessages: [Messageable] {
        return self.allMessages.compactMap { (message) -> Messageable? in
            guard !message.isFromCurrentUser,
                let userID = User.current()?.objectId,
                !message.hasBeenConsumedBy.contains(userID) else { return nil }
            
            return message
        }
    }

    var didGetLastSections: (([ChannelSectionable]) -> Void)?

    func reset() {
        self.allMessages = []
        self.sections = []
        self.messagesObject = nil 
    }

    //MARK: GET MESSAGES

    @discardableResult
    func getLastMessages(batchAmount: UInt = 20) -> Future<[ChannelSectionable]> {
        let promise = Promise<[ChannelSectionable]>()

        var tchChannel: TCHChannel?

        if let activeChannel = ChannelSupplier.shared.activeChannel.value {
            switch activeChannel.channelType {
            case .system(_):
                break
            case .pending(_):
                break 
            case .channel(let channel):
                tchChannel = channel
            }
        }

        if let channel = tchChannel, let messagesObject = channel.messages {
            self.messagesObject = messagesObject
            messagesObject.getLastWithCount(batchAmount) { (result, messages) in
                if let msgs = messages {
                    self.allMessages = msgs
                    let sections = self.mapMessagesToSections(for: msgs, in: .channel(channel))
                    self.sections = sections
                    promise.resolve(with: sections)
                } else {
                    promise.reject(with: ClientError.message(detail: "Failed to retrieve last messages."))
                }
                self.didGetLastSections?(self.sections)
            }
        } else {
            promise.reject(with: ClientError.message(detail: "Failed to retrieve last messages."))
        }

        return promise
    }

    func getMessages(before index: UInt,
                     batchAmount: UInt = 20,
                     for channel: TCHChannel) -> Future<[ChannelSectionable]> {

        let promise = Promise<[ChannelSectionable]>()

        if let messagesObject = channel.messages {
            self.messagesObject = messagesObject
            messagesObject.getBefore(index, withCount: batchAmount) { (result, messages) in
                if let msgs = messages {
                    self.allMessages.insert(contentsOf: msgs, at: 0)
                    let sections = self.mapMessagesToSections(for: self.allMessages, in: .channel(channel))
                    self.sections = sections
                    promise.resolve(with: sections)
                } else {
                    promise.reject(with: ClientError.message(detail: "Failed to retrieve messages."))
                }
            }
        } else {
            promise.reject(with: ClientError.message(detail: "Failed to retrieve messages."))
        }

        return promise
    }

    func mapMessagesToSections(for messages: [Messageable], in channelable: ChannelType) -> [ChannelSectionable] {

        var sections: [ChannelSectionable] = []

        messages.forEach { (message) in

            // Determine if the message is a part of the latest channel section
            let messageCreatedAt = message.createdAt

            if let latestSection = sections.last, latestSection.date.isSameDay(as: messageCreatedAt) {
                // If the message fits into the latest section, then just append it
                latestSection.items.append(message)
            } else {
                // Otherwise, create a new section with the date of this message
                let section = ChannelSectionable(date: messageCreatedAt.beginningOfDay,
                                                 items: [message],
                                                 channelType: channelable)
                sections.append(section)
            }
        }

        return sections
    }

    func delete(message: Messageable) {
        guard let tchMessage = message as? TCHMessage, let messagesObject = self.messagesObject else { return }
        messagesObject.remove(tchMessage, completion: nil)
    }

    func update(message: Messageable, text: String, completion: ((SystemMessage, Error?) -> Void)?) -> SystemMessage {

        let updatedMessage = SystemMessage(with: message)
        updatedMessage.kind = .text(text)

        if let tchMessage = message as? TCHMessage {
            tchMessage.updateBody(text) { (result) in
                if let error = result.error {
                    completion?(updatedMessage, error)
                    print(error)
                } else {
                    completion?(updatedMessage, nil)
                }
            }
        }

        return updatedMessage
    }
}
