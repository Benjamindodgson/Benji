//
//  PushPayload.swift
//  Benji
//
//  Created by Benji Dodgson on 1/26/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import UserNotifications

enum PushType: String {
    case alert
    case background
}

enum PushPriority: Int {
    case high = 10
    case medium = 5
    case low = 1
    case none = 0
}

enum PushBadgeOption: String {
    case increment = "Increment"
    case none = "0"
    case one = "1"
}

struct PushPayload {

    var alert: String
    var title: String

    var paramaters: [String: Any] {
        var params: [String: Any] = [:]
        params["alert"] = self.alert
        params["title"] = self.title
        return params
    }
}

struct PushAPSPayload {

    var alert: String
    var title: String
    var badge: PushBadgeOption = .none
    var sound: String = String()
    var pushType: PushType = .alert
    var priority: PushPriority = .high
    var category: UNNotificationCategory? = nil

    var paramaters: [String: Any] {
        var params: [String: Any] = [:]
        params["alert"] = self.alert
        params["title"] = self.title
        params["badge"] = self.badge.rawValue
        params["sound"] = self.sound
        params["push_type"] = self.pushType
        return params
    }
}

struct PushAlertPayload {

    var paramaters: [String: Any] {
        let params: [String: Any] = [:]
        return params
    }
}

