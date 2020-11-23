//
//  AppDelegate.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let rootNavController = RootNavigationController()
        self.initializeKeyWindow(with: rootNavController)
        self.initializeMainCoordinator(with: rootNavController, withOptions: launchOptions)
        UserDefaults.standard.set(nil, forKey: Routine.currentRoutineKey)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UserNotificationManager.shared.clearNotificationCenter()
        guard !ChannelManager.shared.isConnected, let _ = User.current()?.objectId else { return }

        GetChatToken()
            .makeRequest()
            .observeValue { (token) in
                if ChannelManager.shared.client.isNil {
                    ChannelManager.shared.initialize(token: token)
                } else {
                    ChannelManager.shared.update(token: token)
                }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserNotificationManager.shared.registerPush(from: deviceToken)
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return LaunchManager.shared.continueUser(activity: userActivity)
    }

    func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard application.applicationState == .active || application.applicationState == .inactive else {
            completionHandler(.noData)
            return
        }

        if UserNotificationManager.shared.handle(userInfo: userInfo) {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
}

