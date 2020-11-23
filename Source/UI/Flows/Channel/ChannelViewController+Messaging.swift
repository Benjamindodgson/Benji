//
//  ChannelViewController+Messaging.swift
//  Benji
//
//  Created by Benji Dodgson on 6/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

extension ChannelViewController: MessageInputAccessoryViewDelegate {

    func attachmentView(_ controller: AttachmentViewController, didSelect attachment: Attachement) {
        // add attachment to the message input view
        self.messageInputAccessoryView.expandingTextView.toggleInputView()
    }

    func messageInputAccessoryDidTapContext(_ view: MessageInputAccessoryView) {
        self.delegate.channelViewControllerDidTapContext(self)
    }

    func messageInputAccessory(_ view: MessageInputAccessoryView, didUpdate message: Messageable, with text: String) {
        self.update(message: message, text: text)
    }

    func messageInputAccessory(_ view: MessageInputAccessoryView, didSend text: String, context: MessageContext, attributes: [String : Any]) {
        self.send(messageKind: .text(text), context: context, attributes: attributes)
    }

    func load(activeChannel: DisplayableChannel) {
        switch activeChannel.channelType {
        case .system(_):
            break
        case .pending(_):
            break
        case .channel(let channel):
            channel.delegate = self
            self.loadMessages(for: activeChannel.channelType)
        }
    }

    func send(messageKind: MessageKind,
              context: MessageContext = .casual,
              attributes: [String : Any]) {

        guard let systemMessage = MessageDeliveryManager.shared.send(context: context,
                                                                     kind: messageKind,
                                                                     attributes: attributes,
                                                                     completion: { (message, error) in
                                                                        if let msg = message, let e = error {
                                                                            msg.status = .error
                                                                            self.collectionViewManager.updateItem(with: msg)
                                                                            print(e)
                                                                        }
        }) else { return }

        self.collectionViewManager.append(item: systemMessage) { [unowned self] in
            self.collectionView.scrollToEnd()
        }

        self.messageInputAccessoryView.reset()
    }

    func resend(message: Messageable) {
        
        guard let systemMessage = MessageDeliveryManager.shared.resend(message: message, completion: { (newMessage, error) in
            if let msg = newMessage, let e = error {
                msg.status = .error
                self.collectionViewManager.updateItem(with: msg)
                print(e)
            }
        }) else { return }

        self.collectionViewManager.updateItem(with: systemMessage)
    }

    func update(message: Messageable, text: String) {
        let updatedMessage = MessageSupplier.shared.update(message: message, text: text) { (msg, error) in
            if let e = error {
                msg.status = .error
                self.collectionViewManager.updateItem(with: msg)
                print(e)
            }
        }

        self.indexPathForEditing = nil
        self.collectionViewManager.updateItem(with: updatedMessage)
        self.messageInputAccessoryView.reset()
    }
}

extension ChannelViewController: TCHChannelDelegate {

    func chatClient(_ client: TwilioChatClient,
                    channel: TCHChannel,
                    member: TCHMember,
                    updated: TCHMemberUpdate) {
        print("Channel Member updated")
    }

    func chatClient(_ client: TwilioChatClient,
                    channel: TCHChannel,
                    message: TCHMessage,
                    updated: TCHMessageUpdate) {

        self.collectionViewManager.updateItem(with: message)
    }
}
