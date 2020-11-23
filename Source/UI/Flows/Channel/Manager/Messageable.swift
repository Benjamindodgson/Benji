//
//  Messageable.swift
//  Benji
//
//  Created by Benji Dodgson on 11/9/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization
import TwilioChatClient
import TMROFutures

enum MessageStatus: String {
    case sent //Message was sent as a system message
    case delivered //Message was successfully delivered by Twilio
    case unknown
    case error
}

protocol Messageable: class {

    var createdAt: Date { get }
    var isFromCurrentUser: Bool { get }
    var authorID: String { get }
    var messageIndex: NSNumber? { get }
    var attributes: [String: Any]? { get }
    var avatar: Avatar { get }
    var id: String { get }
    var updateId: String? { get }
    var status: MessageStatus { get }
    var context: MessageContext { get }
    var canBeConsumed: Bool { get }
    var isConsumed: Bool { get }
    var hasBeenConsumedBy: [String] { get }
    var color: Color { get }
    var kind: MessageKind { get }
    func udpateConsumers(with consumer: Avatar) -> Future<Void>
    func appendAttributes(with attributes: [String: Any]) -> Future<Void>
}

func ==(lhs: Messageable, rhs: Messageable) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    return lhs.createdAt == rhs.createdAt
        && lhs.kind == rhs.kind
        && lhs.authorID == rhs.authorID
        && lhs.messageIndex == rhs.messageIndex
        && lhs.id == rhs.id
}

extension Messageable {

    var updateId: String? {
        return nil 
    }

    var canBeConsumed: Bool {
        return self.context != .status
    }

    var isConsumed: Bool {
        return self.hasBeenConsumedBy.count > 0 
    }

    func appendAttributes(with attributes: [String: Any]) -> Future<Void>  {
        return Promise<Void>()
    }

    var color: Color {
        if self.isFromCurrentUser {
            if self.isConsumed {
                return .background3
            } else {
                if self.context == .casual {
                    return .lightPurple
                } else {
                    return self.context.color
                }
            }
        } else {
            if self.isConsumed {
                return .purple
            } else if self.context == .status {
                return self.context.color
            } else {
                return .clear
            }
        }
    }
}
