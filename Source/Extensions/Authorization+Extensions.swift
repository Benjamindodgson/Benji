//
//  AuthorizationManager.swift
//  Benji
//
//  Created by Martin Young on 8/20/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {

    func requestAuthorization() -> Future<Bool> {
        let isGrantedPromise = Promise<Bool>()

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        self.requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                isGrantedPromise.reject(with: error)
            } else {
                isGrantedPromise.resolve(with: granted)
            }
        }

        return isGrantedPromise
    }
}
