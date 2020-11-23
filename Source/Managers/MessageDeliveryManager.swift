//
//  MessageDeliveryManager.swift
//  Benji
//
//  Created by Benji Dodgson on 5/25/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROFutures
import TMROLocalization

class MessageDeliveryManager {

    static let shared = MessageDeliveryManager()
    //private var options: TCHMessageOptions?

    func send(context: MessageContext = .casual,
              kind: MessageKind,
              attributes: [String: Any],
              completion: @escaping (SystemMessage?, Error?) -> Void) -> SystemMessage? {

        if let channelDisplayable = ChannelSupplier.shared.activeChannel.value {
            if let current = User.current(), let objectId = current.objectId {

                var mutableAttributes = attributes
                mutableAttributes["updateId"] = UUID().uuidString

                let systemMessage = SystemMessage(avatar: current,
                                                  context: context,
                                                  isFromCurrentUser: true,
                                                  createdAt: Date(),
                                                  authorId: objectId,
                                                  messageIndex: nil,
                                                  status: .sent,
                                                  kind: kind,
                                                  id: String(),
                                                  attributes: mutableAttributes)

                if case .channel(let channel) = channelDisplayable.channelType {
                    self.sendMessage(to: channel,
                                     context: context,
                                     kind: kind,
                                     attributes: mutableAttributes)
                        .observe { (result) in
                            switch result {
                            case .success(_):
                                completion(systemMessage, nil)
                            case .failure(let error):
                                completion(systemMessage, error)
                            }
                    }
                } else {

                }

                return systemMessage

            } else {
                completion(nil, ClientError.message(detail: "No id found for the current user."))
            }
        } else {
            completion(nil, ClientError.message(detail: "No active channel found."))
        }

        return nil
    }

    func resend(message: Messageable, completion: @escaping (SystemMessage?, Error?) -> Void) -> SystemMessage? {

        if let channelDisplayable = ChannelSupplier.shared.activeChannel.value {
            let systemMessage = SystemMessage(with: message)

            if case .channel(let channel) = channelDisplayable.channelType {
                let attributes = message.attributes ?? [:]
                self.sendMessage(to: channel,
                                 context: message.context,
                                 kind: message.kind,
                                 attributes: attributes)
                    .observe { (result) in
                        switch result {
                        case .success(_):
                            completion(systemMessage, nil)
                        case .failure(let error):
                            completion(systemMessage, error)
                        }
                }
            } else {
                completion(nil, ClientError.message(detail: "No active channel found."))
            }

            return systemMessage
        } else {
            completion(nil, ClientError.message(detail: "No active channel found."))
        }

        return nil 
    }

    //MARK: MESSAGE HELPERS

    private func sendMessage(to channel: TCHChannel,
                             context: MessageContext = .casual,
                             kind: MessageKind,
                             attributes: [String : Any] = [:]) -> Future<Messageable> {
        let promise = Promise<Messageable>()

        if let messagesObject = channel.messages {

            var mutableAttributes = attributes
            mutableAttributes["context"] = context.rawValue

            if !ChannelManager.shared.isConnected {
                promise.reject(with: ClientError.message(detail: "Chat service is disconnected."))
            }

            if channel.status != .joined {
                promise.reject(with: ClientError.message(detail: "You are not a channel member."))
            }

            self.getOptions(for: kind, attributes: attributes)
                .observeValue { (options) in
                    messagesObject.sendMessage(with: options, completion: { (result, message) in
                        if result.isSuccessful(), let msg = message {
                            promise.resolve(with: msg)
                        } else if let e = result.error {
                            promise.reject(with: e)
                        } else {
                            promise.reject(with: ClientError.message(detail: "Failed to send message."))
                        }
                    })
            }
        } else {
            promise.reject(with: ClientError.message(detail: "No messages object on channel"))
        }

        return promise.withResultToast()
    }

    private func getOptions(for kind: MessageKind, attributes: [String : Any] = [:]) -> Future<TCHMessageOptions> {

        let options = TCHMessageOptions()
        let promise = Promise<TCHMessageOptions>()

        switch kind {
        case .text(let body):
            options.with(body: body, attributes: TCHJsonAttributes.init(dictionary: attributes))
                .observe { (result) in
                    switch result {
                    case .success(let newOptions):
                        promise.resolve(with: newOptions)
                    case .failure(let error):
                        promise.reject(with: error)
                    }
            }
        case .attributedText(_):
            break
        case .photo(let item):
            options.with(mediaItem: item, attributes: TCHJsonAttributes.init(dictionary: attributes))
                .observe { (result) in
                    switch result {
                    case .success(let newOptions):
                        promise.resolve(with: newOptions)
                    case .failure(let error):
                        promise.reject(with: error)
                    }
            }
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        }

        return promise
    }
}
