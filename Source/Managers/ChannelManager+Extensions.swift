//
//  ChannelManager+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 4/27/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

typealias CompletionHandler = (_ success: Bool, _ error: Error?) -> Void
typealias ClientCompletion = (_ client: TwilioChatClient, _ error: Error?) -> Void
typealias ChannelsCompletion = (_ channel: [TCHChannel], _ error: Error?) -> Void
typealias ChannelCreationCompletion = (_ channel: TCHChannel?, _ error: Error?) -> Void

struct ChatClientUpdate {
    var client: TwilioChatClient
    var status: Status

    enum Status {
        case sync(TCHClientSynchronizationStatus)
        case connectionState(TCHClientConnectionState)
        case userUpdate(TCHUser, TCHUserUpdate)
        case toastSubscribed
        case toastRegistrationFailed(TCHError)
        case error(TCHError)
    }
}

struct ChannelUpdate {
    var channel: TCHChannel
    var status: Status

    enum Status {
        case added
        case changed
        case deleted
        case syncUpdate(TCHChannelSynchronizationStatus)
    }
}

struct MessageUpdate {
    var channel: TCHChannel
    var message: TCHMessage
    var status: Status

    enum Status {
        case added
        case changed
        case deleted
        case toastReceived
    }
}

struct ChannelMemberUpdate {
    var channel: TCHChannel
    var member: TCHMember
    var status: Status

    enum Status {
        case joined
        case left
        case changed
        case typingEnded
        case typingStarted
    }
}

extension ChannelManager: TwilioChatClientDelegate {

    //MARK: CLIENT UDPATES

    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {

        switch status {
        case .started:
            print("STATUS CHANGED TO: STARTED")
        case .channelsListCompleted:
            print("STATUS CHANGED TO: CHANNEL LIST COMPLETED")
        case .completed:
            print("STATUS CHANGED TO: COMPLETED")
        case .failed:
            print("STATUS CHANGED TO: FAILED")
        @unknown default:
            break
        }

        self.clientUpdate.value = ChatClientUpdate(client: client, status: .sync(status))
    }

    func chatClient(_ client: TwilioChatClient, connectionStateUpdated state: TCHClientConnectionState) {
        self.clientUpdate.value = ChatClientUpdate(client: client, status: .connectionState(state))
    }

    func chatClient(_ client: TwilioChatClient, user: TCHUser, updated: TCHUserUpdate) {
        self.clientUpdate.value = ChatClientUpdate(client: client, status: .userUpdate(user, updated))
    }

    func chatClientToastSubscribed(_ client: TwilioChatClient!) {
        self.clientUpdate.value = ChatClientUpdate(client: client, status: .toastSubscribed)
    }

    func chatClient(_ client: TwilioChatClient!, toastRegistrationFailedWithError error: TCHError!) {
        self.clientUpdate.value = ChatClientUpdate(client: client, status: .toastRegistrationFailed(error))
    }

    func chatClient(_ client: TwilioChatClient, errorReceived error: TCHError) {
        self.clientUpdate.value = ChatClientUpdate(client: client, status: .error(error))
    }

    //MARK: CHANNEL UPDATES

    func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {

        if channel.status == TCHChannelStatus.invited {
            channel.join() { result in
                if result.isSuccessful() {
                    self.channelsUpdate.value = ChannelUpdate(channel: channel, status: .added)
                }
            }
        } else {
            self.channelsUpdate.value = ChannelUpdate(channel: channel, status: .added)
        }
    }

    func chatClient(_ client: TwilioChatClient!, channelChanged channel: TCHChannel!) {
        self.channelsUpdate.value = ChannelUpdate(channel: channel, status: .changed)
    }

    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        self.channelsUpdate.value = ChannelUpdate(channel: channel, status: .deleted)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        self.channelsUpdate.value = ChannelUpdate(channel: channel, status: .syncUpdate(status))
    }

    //MARK: MEMBER UDPATES

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .left)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .joined)
    }

    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, memberChanged member: TCHMember!) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .changed)
    }

    func chatClient(_ client: TwilioChatClient, typingEndedOn channel: TCHChannel, member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .typingEnded)
    }

    func chatClient(_ client: TwilioChatClient, typingStartedOn channel: TCHChannel, member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .typingStarted)
    }

    //MARK: MESSAGE UPDATES

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .added)
    }

    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, messageChanged message: TCHMessage!) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .changed)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageDeleted message: TCHMessage) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .deleted)
    }

    func chatClient(_ client: TwilioChatClient!, toastReceivedOn channel: TCHChannel!, message: TCHMessage!) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .toastReceived)
    }
}

