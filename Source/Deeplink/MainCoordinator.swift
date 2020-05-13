//
//  MainCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

class MainCoordinator: Coordinator<Void> {

    var launchOptions: [UIApplication.LaunchOptionsKey : Any]?

    var isInitializingChat: Bool = false

    private lazy var splashVC = SplashViewController()

    override func start() {
        super.start()

        SessionManager.shared.didReceiveInvalidSessionError = { [unowned self] _ in
            self.showLogOutAlert()
        }

        UserNotificationManager.shared.delegate = self
        LaunchManager.shared.delegate = self

        self.runLaunchFlow()
    }

    private func runLaunchFlow() {
        LaunchManager.shared.launchApp(with: self.launchOptions)
        self.router.setRootModule(self.splashVC, animated: true)
    }

    func handle(result: LaunchStatus) {

        switch result {
        case .isLaunching:
            break
        case .needsOnboarding:
            runMain {
                self.runOnboardingFlow()
            }
        case .success(let object, let token):
            self.deepLink = object

            if ChannelManager.shared.isConnected {
                self.runHomeFlow()
            } else {
                self.initializeChat(with: token)
            }
        case .failed(_):
            break
        case .deeplink(let object):
            self.deepLink = object
            self.handle(deeplink: object)
        }
    }

    private func initializeChat(with token: String) {
        // Fixes double loading. 
        guard !self.isInitializingChat else { return }

        self.isInitializingChat = true
        ChannelManager.initialize(token: token)
            .withResultToast()
            .observeValue(with: { (_) in
                self.isInitializingChat = false
                guard let user = User.current(), user.isOnboarded else { return }
                self.runHomeFlow()
            })
    }

    private func runHomeFlow() {
        if let homeCoordinator = self.childCoordinator as? HomeCoordinator, let deepLink = self.deepLink {
            homeCoordinator.handle(deeplink: deepLink)
        } else {
            self.removeChild()
            let homeCoordinator = HomeCoordinator(router: self.router, deepLink: self.deepLink)
            self.router.setRootModule(homeCoordinator, animated: true)
            self.addChildAndStart(homeCoordinator, finishedHandler: { _ in
                // If the home coordinator ever finishes, put handling logic here.
            })
        }
    }

    private func runOnboardingFlow() {
        if let onboardingCoordinator = self.childCoordinator as? OnboardingCoordinator, let deepLink = self.deepLink {
            onboardingCoordinator.handle(deeplink: deepLink)
        } else {
            let coordinator = OnboardingCoordinator(reservationId: self.deepLink?.reservationId,
                                                    reservationCreatorId: self.deepLink?.reservationCreatorId,
                                                    router: self.router,
                                                    deepLink: self.deepLink)
            self.router.setRootModule(coordinator, animated: true)
            self.addChildAndStart(coordinator, finishedHandler: { (_) in
                self.router.dismiss(source: coordinator.toPresentable(), animated: true) {
                    self.runHomeFlow()
                }
            })
        }
    }

    private func handle(deeplink: DeepLinkable) {
        guard let string = deeplink.customMetadata["target"] as? String,
            let target = DeepLinkTarget(rawValue: string)  else { return }

        switch target {
        case .home, .channel, .channels, .routine, .profile, .feed:
            if let user = User.current(), user.isAuthenticated {
                self.runHomeFlow()
            }
        case .login:
            if let user = User.current(), user.isAuthenticated {
                self.runHomeFlow()
            } else {
                self.runOnboardingFlow()
            }
        }
    }

    private func showLogOutAlert() {
        let alert = UIAlertController(title: "🙀",
                                      message: "Someone tripped over a 🐈 and ☠️ the mainframe.",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.logOut()
        }

        alert.addAction(ok)

        self.router.topmostViewController.present(alert, animated: true, completion: nil)
    }

    private func logOut() {
        ChannelManager.shared.client?.shutdown()
        self.deepLink = nil
        self.removeChild()
        self.runOnboardingFlow()
    }
}

extension MainCoordinator: UserNotificationManagerDelegate {
    func userNotificationManager(willHandle deeplink: DeepLinkable) {
        self.deepLink = deeplink
        self.handle(deeplink: deeplink)
    }
}

extension MainCoordinator: LaunchManagerDelegate {
    func launchManager(_ manager: LaunchManager, didFinishWith status: LaunchStatus) {
        self.handle(result: status)
    }
}

