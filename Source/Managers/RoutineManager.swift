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

    static let shared = RoutineManager()

    var currentRoutine: Routine? {
        didSet {
            guard let routine = self.currentRoutine else { return }

            let notificationCenter = UNUserNotificationCenter.current()

            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            notificationCenter.requestAuthorization(options: options) { (granted, error) in
                if granted {
                    self.scheduleNotification(for: routine)
                } else {
                    print("User has declined notifications")
                }
            }
        }
    }

    func scheduleNotification(for routine: Routine) {

        let notificationCenter = UNUserNotificationCenter.current()

        let identifier = "Local Notification"

        let content = UNMutableNotificationContent()
        content.title = "Test title"
        content.body = "Test body"
        content.sound = UNNotificationSound.default
        content.badge = 1

        let timeComponent = Calendar.current.dateComponents([.hour, .minute],
                                                            from: routine.messageCheckTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponent,
                                                    repeats: false)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
