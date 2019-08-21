//
//  RoutineManager.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import UserNotifications

class RoutineManager {

    let messageReminderID = "MessageReminderID"

    static let shared = RoutineManager()

    func getRoutineNotifications() -> Future<[UNNotificationRequest]> {
        let requestsPromise = Promise<[UNNotificationRequest]>()

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { (requests) in
            let routineRequests = requests.filter { (request) -> Bool in
                return request.identifier.contains(self.messageReminderID)
            }
            requestsPromise.resolve(with: routineRequests)
        }

        return requestsPromise
    }

    func scheduleNotification(for routine: Routine) {

        let identifier = self.messageReminderID + routine.timeDescription

        let notificationCenter = UNUserNotificationCenter.current()

        // Replace any previous notifications
        notificationCenter.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "New Messages"
        content.body = "It's time to check your messages!"
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: routine.timeComponents,
                                                    repeats: true)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                print("Scheduled notification for \(routine.timeDescription)")
            }
        }
    }
}
