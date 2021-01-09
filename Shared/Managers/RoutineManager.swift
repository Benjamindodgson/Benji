//
//  RoutineManager.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import UserNotifications
import Combine

class RoutineManager {

    let messageReminderID = "MessageReminderID"
    let lastChanceReminderID = "LastChanceReminderID"

    static let shared = RoutineManager()
    private var cancellables = Set<AnyCancellable>()

    func getRoutineNotifications() -> Future<[UNNotificationRequest], Never> {
        return Future { promise in
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.getPendingNotificationRequests { (requests) in
                let routineRequests = requests.filter { (request) -> Bool in
                    return request.identifier.contains(self.messageReminderID)
                }
                promise(.success(routineRequests))
            }
        }
    }

    func scheduleNotification(for routine: Ritual) {

        let identifier = self.messageReminderID + routine.timeDescription

        // Replace any previous notifications
        UserNotificationManager.shared.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Feed Unlocked"
        content.body = "Your daily feed is unlocked for the next hour."
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "routine"

        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: routine.timeComponents,
                                                    repeats: true)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UserNotificationManager.shared.schedule(note: request)
            .mainSink(receiveValue: { (_) in
                self.scheduleLastChanceNotification(for: routine)
            }).store(in: &self.cancellables)
    }

    func scheduleLastChanceNotification(for routine: Ritual) {

        let identifier = self.lastChanceReminderID

        let content = UNMutableNotificationContent()
        content.title = "Last Chance"
        content.body = "You have 10 mins left to check your feed for the day."
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "routine"

        var lastChanceTime: DateComponents = routine.timeComponents
        if let minutes = routine.timeComponents.minute {
            var min = minutes + 50
            var hour = routine.timeComponents.hour ?? 0
            if min > 60 {
                min -= 60
                hour += 1
            }
            lastChanceTime.minute = min
            lastChanceTime.hour = hour
        } else {
            lastChanceTime.minute = 50
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: lastChanceTime,
                                                    repeats: true)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UserNotificationManager.shared.schedule(note: request)
            .mainSink(receiveValue: { (_) in }).store(in: &self.cancellables)
    }
}
