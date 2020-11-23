//
//  HomeCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class HomeCoordinator: PresentableCoordinator<Void> {

    private lazy var homeVC = HomeViewController(with: self)

    override func toPresentable() -> DismissableVC {
        return self.homeVC
    }

    override func start() {
        super.start()

        ToastScheduler.shared.delegate = self

        self.homeVC.currentContent.producer.on(value:  { [unowned self] (contentType) in
            self.removeChild()
            
            // Only use the deeplink once so that we don't repeatedly try
            // to deeplink whenever content changes.
            defer {
                self.deepLink = nil
            }
            
            switch contentType {
            case .feed(let vc):
                let coordinator = FeedCoordinator(router: self.router,
                                                  deepLink: self.deepLink,
                                                  feedVC: vc)
                self.addChildAndStart(coordinator) { (_) in }
            case .channels(let vc):
                let coordinator = ChannelsCoordinator(router: self.router,
                                                      deepLink: self.deepLink,
                                                      channelsVC: vc)
                self.addChildAndStart(coordinator) { (_) in }
            case .profile(let vc):
                let coordinator = ProfileCoordinator(router: self.router,
                                                     deepLink: self.deepLink,
                                                     profileVC: vc)
                self.addChildAndStart(coordinator) { (_) in }
            }
        }).start()

        if let deeplink = self.deepLink {
            self.handle(deeplink: deeplink)
        }
    }

    func handle(deeplink: DeepLinkable) {
        self.deepLink = deeplink

        guard let target = deeplink.deepLinkTarget else { return }

        switch target {
        case .reservation:
            break // show a reservation alert. 
        case .home:
            break
        case .login:
            break
        case .channel:
            if let channelId = deeplink.customMetadata["channelId"] as? String,
                let channel = ChannelSupplier.shared.getChannel(withSID: channelId) {
                self.startChannelFlow(for: channel.channelType)
            }
        case .routine:
            self.startRoutineFlow()
        case .profile:
             self.homeVC.currentContent.value = .profile(self.homeVC.profileVC)
        case .feed:
            self.homeVC.currentContent.value = .feed(self.homeVC.feedVC)
        case .channels:
            self.homeVC.currentContent.value = .channels(self.homeVC.channelsVC)
        }
    }

    private func startRoutineFlow() {
        let coordinator = RoutineCoordinator(router: self.router, deepLink: self.deepLink)
        self.addChildAndStart(coordinator) { (result) in }
        let source = self.homeVC.currentCenterVC ?? self.homeVC
        self.router.present(coordinator, source: source)
    }
}

extension HomeCoordinator: HomeViewControllerDelegate {

    func homeViewDidTapAdd(_ controller: HomeViewController) {
        self.removeChild()

        let coordinator = NewChannelCoordinator(router: self.router, deepLink: self.deepLink)

        self.addChildAndStart(coordinator) { (result) in
            self.router.dismiss(source: coordinator.toPresentable(), animated: true) {
                self.startChannelFlow(for: nil)
            }
        }

        self.router.present(coordinator, source: self.homeVC, animated: true)
    }

    func startChannelFlow(for type: ChannelType?) {
        self.removeChild()
        var channel: DisplayableChannel?
        if let t = type {
            channel = DisplayableChannel(channelType: t)
        }
        let coordinator = ChannelCoordinator(router: self.router, deepLink: self.deepLink, channel: channel)
        self.addChildAndStart(coordinator, finishedHandler: { (_) in
            self.router.dismiss(source: coordinator.toPresentable(), animated: true) {
                self.finishFlow(with: ())
            }
        })
        self.router.present(coordinator, source: self.homeVC, animated: true)
    }
}

extension HomeCoordinator: ToastSchedulerDelegate {

    func didInteractWith(type: ToastType) {
        switch type {
        case .systemMessage(_):
            break
        case .message(_, let channel), .channel(let channel):
            self.startChannelFlow(for: .channel(channel))
        case .error(_):
            break
        case .success(_):
            break
        case .userStatusUpdateInChannel(_, _, let channel):
            self.startChannelFlow(for: .channel(channel))
        case .messageConsumed(_, _):
            break 
        }
    }
}
