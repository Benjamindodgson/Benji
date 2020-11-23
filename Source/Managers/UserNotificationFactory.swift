//
//  UserNotificationFactory.swift
//  Benji
//
//  Created by Benji Dodgson on 4/19/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// Class responsible for parsing remote notification payload and creating a local notification for presentation.
class UserNotificationFactory {

    static func createNote(from data: [String: Any]) -> UNNotificationRequest? {
        let content = UNMutableNotificationContent()

        guard let body: String = self.valueFrom(data: data, for: .body),
            let title: String = self.valueFrom(data: data, for: .title),
            let identifier: String = self.valueFrom(data: data, for: .identifier) else { return nil }

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        content.setUserInfo(from: data)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: nil)

        return request
    }

    static func valueFrom<Type>(data: [String: Any], for key: NotificationContentKey) -> Type? {
        return data[key.rawValue] as? Type
    }
}
