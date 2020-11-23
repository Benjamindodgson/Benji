//
//  UNNotificationContent+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 4/19/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum NotificationContentKey: String {
    case target = "target"
    case group = "group"
    case deeplink = "deeplink"
    case identifier = "identifier"
    case body = "body"
    case title = "title"
    case subtitle = "subtitle"
    case trigger = "trigger"
    case category = "categoryIdentifier"
    case thread = "threadIdentifier"
    case channelId = "channelId"
    case messageId = "messageId"
}

extension UNNotificationContent {

    var deepLinkTarget: DeepLinkTarget? {
        guard let value: String = self.value(for: .target) else { return nil }
        return DeepLinkTarget(rawValue: value)
    }

    var deeplinkURL: URL? {
        guard let value: String = self.value(for: .deeplink) else { return nil }
        return URL(string: value)
    }

    var identifier: String? {
        return self.value(for: .identifier)
    }

    func value<Type>(for key: NotificationContentKey) -> Type? {
        guard let data = self.userInfo["data"] as? [String: Any] else { return nil }
        return data[key.rawValue] as? Type
    }

    func valueFrom<Type>(data: [String: Any], for key: NotificationContentKey) -> Type? {
        return data[key.rawValue] as? Type
    }
}

extension UNMutableNotificationContent {

    func setUserInfo(from data: [String: Any]) {
        self.setValue(for: .target, from: data)
        self.setValue(for: .deeplink, from: data)
        self.setValue(for: .identifier, from: data)

        if let subtitle: String = self.valueFrom(data: data, for: .subtitle) {
            self.subtitle = subtitle
        }

        if let category: String = self.valueFrom(data: data, for: .category) {
            self.categoryIdentifier = category
        }

        if let thread: String = self.valueFrom(data: data, for: .thread) {
            self.threadIdentifier = thread
        }

        self.userInfo = data
    }

    func setValue(for key: NotificationContentKey, from data: [String: Any]) {
        self.userInfo[key.rawValue] = data[key.rawValue]
    }
}

