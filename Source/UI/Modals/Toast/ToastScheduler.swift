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
        case .userStatusUpdateInChannel(let user, let status, let channel):
            toast = self.createUserInChannelToast(for: user, status: status, channel: channel)
        case .channel(let channel):
            toast = self.createChannelToast(for: channel)
        case .error(let error):
            toast = self.createErrorToast(for: error)
        case .success(let text): 
            toast = self.createSuccessToast(for: text)
        }

        if let toast = toast {
            ToastQueue.shared.add(toast: toast)
        }
    }

    private func createSystemMessageToast(for systemMessage: SystemMessage) -> Toast? {
        let button = LoadingButton()
        button.set(style: .rounded(color: .background3, text: "VIEW")) {

        }
        return Toast(id: systemMessage.id + "system_message",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: systemMessage.text,
                     displayable: UIImage(),
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
                     title: body,
                     displayable: message,
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .message(message, channel))
        })
    }

    private func createUserInChannelToast(for user: User,
                                          status: ChannelMemberUpdate.Status,
                                          channel: TCHChannel) -> Toast? {
        guard let id = user.objectId,
            let handle = user.handle,
            let channelName = channel.friendlyName else { return nil }

        var message: Localized = ""
        switch status {
        case .joined:
            let first = user.isCurrentUser ? "You" : handle
            message = LocalizedString(id: "",
                                      arguments: [first, channelName],
                                      default: "@() joined @()")
        case .left:
            let first = user.isCurrentUser ? "You" : handle
            message = LocalizedString(id: "",
                                      arguments: [first, channelName],
                                      default: "@() left @()")
        case .changed, .typingEnded:
            break
        case .typingStarted:
            message = LocalizedString(id: "",
                                      arguments: [handle, channelName],
                                      default: "@() started typing in @()")
        }

        return Toast(id: id + "userInChannel",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: message,
                     displayable: user,
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .userStatusUpdateInChannel(user, status, channel))
        })
    }

    private func createChannelToast(for channel: TCHChannel) -> Toast? {
        guard let sid = channel.sid, let friendlyName = channel.friendlyName else { return nil }

        let title = LocalizedString(id: "", arguments: [friendlyName], default: "New conversaton added: @(friendlyName)")
        return Toast(id: sid + "channel",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: title,
                     displayable: channel,
                     didTap: {
                        self.delegate?.didInteractWith(type: .channel(channel))
        })
    }

    private func createErrorToast(for error: Error) -> Toast? {
        guard let image = UIImage(named: "error") else { return nil }

        return Toast(id: error.localizedDescription + "error",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: error.localizedDescription,
                     displayable: image,
                     didTap: {
                        self.delegate?.didInteractWith(type: .error(error))
        })
    }

    private func createSuccessToast(for text: Localized) -> Toast? {
        guard let image = UIImage(named: "error") else { return nil }

        return Toast(id: text.identifier + "success",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: localized(text),
                     displayable: image,
                     didTap: {
                        self.delegate?.didInteractWith(type: .success(text))
        })
    }
}
