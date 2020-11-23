//
//  ChannelType.swift
//  Benji
//
//  Created by Benji Dodgson on 6/24/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization

enum ChannelType: ManageableCellItem {

    case system(SystemChannel)
    case channel(TCHChannel)
    case pending(String)

    var uniqueName: String {
        switch self {
        case .system(let channel):
            return channel.uniqueName
        case .channel(let channel):
            return String(optional: channel.friendlyName)
        case .pending(let uniqueName):
            return uniqueName
        }
    }

    var displayName: String {
        switch self {
        case .system(let channel):
            return channel.displayName
        case .channel(let channel):
            return String(optional: channel.friendlyName)
        case .pending(_):
            return String()
        }
    }

    var purpose: String {
        switch self {
        case .system(let channel):
            return localized(channel.context.text)
        case .channel(let channel):
            return String(optional: channel.channelDescription)
        case .pending(_):
            return String()
        }
    }

    var dateUpdated: Date {
        switch self {
        case .system(let systemMessage):
            return systemMessage.timeStampAsDate
        case .channel(let channel):
            return channel.dateUpdatedAsDate ?? Date.distantPast
        case .pending(_):
            return Date()
        }
    }

    var id: String {
        switch self {
        case .system(let systemMessage):
            return systemMessage.id
        case .channel(let channel):
            return channel.id
        case .pending(let uniqueName):
            return uniqueName
        }
    }

    var isFromCurrentUser: Bool {
        switch self {
        case .system(_):
            return true
        case .channel(let channel):
            return channel.createdBy == User.current()?.objectId
        case .pending(_):
            return true 
        }
    }
}
