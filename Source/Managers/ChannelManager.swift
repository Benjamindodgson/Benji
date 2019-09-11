//
//  ChannelManager.swift
//  Benji
//
//  Created by Benji Dodgson on 1/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import ReactiveSwift
import Parse

class ChannelManager: NSObject {

    static let shared = ChannelManager()
    var client: TwilioChatClient?

    var clientSyncUpdate = MutableProperty<TCHClientSynchronizationStatus?>(nil)
    var clientUpdate = MutableProperty<ChatClientUpdate?>(nil)
    var channelSyncUpdate = MutableProperty<ChannelSyncUpdate?>(nil)
    var channelUpdate = MutableProperty<ChannelUpdate?>(nil)
    var messageUpdate = MutableProperty<MessageUpdate?>(nil)
    var memberUpdate = MutableProperty<ChannelMemberUpdate?>(nil)

    var channelTypes: [ChannelType] {
        get {
            guard let client = self.client, let channels = client.channelsList() else { return [] }
            return channels.subscribedChannels().map({ (channel) -> ChannelType in
                return .channel(channel)
            })
        }
    }

    var selectedChannel: TCHChannel?

    var isSynced: Bool {
        guard let client = self.client else { return false }
        if client.synchronizationStatus == .completed || client.synchronizationStatus == .channelsListCompleted {
            return true
        }

        return false
    }

    static func initialize(token: String) {
        TwilioChatClient.chatClient(withToken: token,
                                    properties: nil,
                                    delegate: shared,
                                    completion: { (result, client) in
                                        guard let strongClient = client else { return }
                                        shared.client = strongClient
        })
    }

    func update(token: String, completion: @escaping CompletionHandler) {
        guard let client = self.client else { return }
        client.updateToken(token, completion: { (result) in
            completion(true, nil)
        })
    }

    //MARK: HELPERS

    func getChannels(completion: @escaping ChannelsCompletion) {
        guard let client = self.client, let channels = client.channelsList() else { return }

        let subscribedChannels = channels.subscribedChannels()
        completion(subscribedChannels, nil)
    }

    static func createChannel(channelName: String,
                              channelDescription: String,
                              type: TCHChannelType,
                              attributes: NSMutableDictionary = [:]) -> Future<TCHChannel> {

        guard let client = self.shared.client else {
            let errorMessage = "Unable to create channel. Twilio client uninitialized"
            return Promise<TCHChannel>(error: ClientError.apiError(detail: errorMessage))
        }

        attributes[ChannelKey.description.rawValue] = channelDescription

        return client.createChannel(channelName: channelName,
                                    uniqueName: UUID().uuidString,
                                    type: type,
                                    attributes: attributes)
    }

    func delete(channel: TCHChannel, completion: @escaping CompletionHandler) {
        channel.destroy { result in
            completion(result.isSuccessful() , result.error)
        }
    }

    func joinChannel(sid: String, completion: @escaping ClientCompletion) {
        guard let client = self.client, let channels = client.channelsList() else { return }

        channels.channel(withSidOrUniqueName: sid, completion: { (result, channel) in
            guard let strongChannel = channel else {
                completion(client, result.error)
                return
            }

            if result.isSuccessful(), strongChannel.status != .joined {
                strongChannel.join(completion: { (result) in
                    completion(client, result.error)
                })
            } else {
                completion(client, result.error)
            }
        })
    }

    //MARK: MESSAGE HELPERS

    func sendMessage(to channel: TCHChannel,
                     with body: String,
                     attributes: Dictionary<String, Any> = [:]) {
        let message = body.extraWhitespaceRemoved()

        guard !message.isEmpty, channel.status == .joined else { return }

        if let messages = channel.messages {
            let messageOptions = TCHMessageOptions().withBody(body)
            messageOptions.withAttributes(attributes, completion: nil)
            messages.sendMessage(with: messageOptions, completion: { (result, message) in
                
            })
        }
    }

    func getLatestMessages(channel: TCHChannel, count: Int) {
        guard let messages = channel.messages else { return }

        messages.getLastWithCount(UInt(count), completion: { (result, newMessages) in

        })
    }

    func sendInvite(channel: TCHChannel, identity: String, completion: ((TCHResult) -> Void)?) {
        guard let members = channel.members else { return }

        members.invite(byIdentity: identity) { result in
            completion?(result)
        }
    }

    func update(channel: TCHChannel, withAttributes: Any) {

    }

    func hasChannel(with name: String, completion: @escaping (TCHChannel?) -> Void) {
        guard let client = self.client, let channels = client.channelsList() else {
            completion(nil)
            return
        }

        channels.channel(withSidOrUniqueName: name) { (result, channel) in
            completion(channel)
        }
    }

    //MARK: MAPPING

    func getAllMessages(for channel: TCHChannel, completion: @escaping ([ChannelSectionType]) -> Void) {

        guard let allMessages = channel.messages else { return }

        allMessages.getLastWithCount(100) { (result, messages) in
            guard let strongMessages = messages else { return }

            var sections: [ChannelSectionType] = []

            strongMessages.forEach { (message) in

                // Determine if the message is a part of the latest channel section
                let messageCreatedAt = message.timestampAsDate ?? Date.distantPast

                if let latestSection = sections.last, latestSection.date.isSameDay(as: messageCreatedAt) {
                    // If the message fits into the latest section, then just append it
                    latestSection.items.append(.message(message))
                } else {
                    // Otherwise, create a new section with the date of this message
                    let section = ChannelSectionType(date: messageCreatedAt.beginningOfDay,
                                                     items: [.message(message)])
                    sections.append(section)
                }
            }

            completion(sections)
        }
    }

    private func deleteAllChannels() {

        for type in ChannelManager.shared.channelTypes {
            switch type {
            case .channel(let channel):
                channel.destroy(completion: { (result) in
                    if result.isSuccessful() {
                        print("Channel deleted")
                    }
                })
            default:
                break
            }
        }
    }
}
