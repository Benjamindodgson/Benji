//
//  ToastScheduler.swift
//  Benji
//
//  Created by Benji Dodgson on 7/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization

enum ToastType {
    case systemMessage(SystemMessage)
    case message(TCHMessage, TCHChannel)
    case messageConsumed(TCHMessage, User)
    case userStatusUpdateInChannel(User, ChannelMemberUpdate.Status, TCHChannel)
    case channel(TCHChannel)
    case error(Error)
    case success(Localized)
}

protocol ToastSchedulerDelegate: class {
    func didInteractWith(type: ToastType)
}

class ToastScheduler {
    static let shared = ToastScheduler()

    weak var delegate: ToastSchedulerDelegate?

    func schedule(toastType: ToastType) {

        var toast: Toast?
        switch toastType {
        case .systemMessage(let message):
            toast = self.createSystemMessageToast(for: message)
        case .message(let message, let channel):
            toast = self.createMessageToast(for: message, channel: channel)
        case .messageConsumed(let message, let author):
            toast = self.createMessageConsumedToast(for: message, author: author)
        case .userStatusUpdateInChannel(let user, let status, let channel):
            toast = self.createUserInChannelToast(for: user, status: status, channel: channel)
        case .channel(let channel):
            toast = self.createChannelToast(for: channel)
        case .error(let error):
            toast = self.createErrorToast(for: error)
        case .success(let text): 
            toast = self.createSuccessToast(for: text)
        }

        if let t = toast {
            runMain {
                ToastQueue.shared.add(toast: t)
            }
        }
    }

    private func createSystemMessageToast(for systemMessage: SystemMessage) -> Toast? {
        guard case MessageKind.text(let text) = systemMessage.kind else { return nil }
        let button = LoadingButton()
        button.set(style: .rounded(color: .background3, text: "VIEW")) {

        }
        return Toast(id: systemMessage.id + "system_message",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: systemMessage.avatar.fullName,
                     description: text,
                     avatar: UIImage(),
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .systemMessage(systemMessage))
        })
    }

    private func createMessageToast(for message: TCHMessage, channel: TCHChannel) -> Toast? {
        guard let sid = message.sid,
            let body = message.body,
            !body.isEmpty else { return nil }

        return Toast(id: sid + "message",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: "New Message",
                     description: body,
                     avatar: message,
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .message(message, channel))
        })
    }

    private func createMessageConsumedToast(for message: TCHMessage, author: User) -> Toast? {
        guard let sid = message.sid, message.context == .emergency else { return nil }

        let title = LocalizedString(id: "", arguments: [author.givenName.capitalized], default: "@(name) Notified")
        let body = LocalizedString(id: "", arguments: [author.givenName.capitalized], default: "@(name) has been notified that you read thier important message.")

        return Toast(id: sid + "messageRead",
                     analyticsID: "ToastMessageRead",
                     priority: 1,
                     title: title,
                     description: body,
                     avatar: message,
                     didTap: {})
    }

    private func createUserInChannelToast(for user: User,
                                          status: ChannelMemberUpdate.Status,
                                          channel: TCHChannel) -> Toast? {
        guard let id = user.objectId, let channelName = channel.friendlyName else { return nil }

        var title: Localized = ""
        var description: Localized = ""
        switch status {
        case .joined:
            title = "Joined"
            let first = user.isCurrentUser ? "You" : user.givenName
            description = LocalizedString(id: "toast.joined",
                                          arguments: [first, channelName],
                                          default: "@(name) joined @(channel)")
        case .left:
            title = "User Left"
            let first = user.isCurrentUser ? "You" : user.givenName
            description = LocalizedString(id: "toast.left",
                                          arguments: [first, channelName],
                                          default: "@(name) left @(channel)")
        case .changed, .typingEnded:
            break
        case .typingStarted:
            title = "Typing"
            description = LocalizedString(id: "",
                                          arguments: [user.givenName, channelName],
                                          default: "@(name) started typing in @(channel)")
        }

        return Toast(id: id + "userInChannel",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: title,
                     description: description,
                     avatar: user,
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .userStatusUpdateInChannel(user, status, channel))
        })
    }

    private func createChannelToast(for channel: TCHChannel) -> Toast? {
        guard let sid = channel.sid, let friendlyName = channel.friendlyName else { return nil }

        let description = LocalizedString(id: "", arguments: [friendlyName], default: "New conversaton added: @(friendlyName)")
        return Toast(id: sid + "channel",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: "New",
                     description: description,
                     avatar: channel,
                     didTap: {
                        self.delegate?.didInteractWith(type: .channel(channel))
        })
    }

    private func createErrorToast(for error: Error) -> Toast? {
        guard let image = UIImage(named: "error") else { return nil }

        return Toast(id: error.localizedDescription + "error",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: "Error",
                     description: error.localizedDescription,
                     avatar: image,
                     didTap: {
                        self.delegate?.didInteractWith(type: .error(error))
        })
    }

    private func createSuccessToast(for text: Localized) -> Toast? {
        guard let image = UIImage(named: "error") else { return nil }

        return Toast(id: text.identifier + "success",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: "Success",
                     description: localized(text),
                     avatar: image,
                     didTap: {
                        self.delegate?.didInteractWith(type: .success(text))
        })
    }
}
