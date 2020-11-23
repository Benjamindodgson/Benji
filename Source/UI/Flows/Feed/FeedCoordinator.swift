//
//  FeedCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization

class FeedCoordinator: Coordinator<Void> {

    private let feedVC: FeedViewController

    init(router: Router,
         deepLink: DeepLinkable?,
         feedVC: FeedViewController) {

        self.feedVC = feedVC

        super.init(router: router, deepLink: deepLink)
    }

    override func start() {
        self.feedVC.delegate = self
    }
}

extension FeedCoordinator: FeedViewControllerDelegate {

    func feedView(_ controller: FeedViewController, didSelect item: FeedType) {
        self.handle(item: item)
    }

    private func handle(item: FeedType) {

        switch item {
        case .timeSaved, .system(_):
            break
        case .rountine:
            self.startRoutineFlow()
        case .unreadMessages(let channel, _):
            self.startChannelFlow(for: .channel(channel))
        case .channelInvite(let channel):
            self.startChannelFlow(for: .channel(channel))
        case .newChannel(let channel):
            self.startChannelFlow(for: channel.channelType)
        case .inviteAsk(let reservation):
            self.startReservationFlow(with: reservation)
        case .notificationPermissions:
            break
        case .connectionRequest(_):
            break
        case .meditation:
            self.showMeditation()
        }
    }

    private func startReservationFlow(with reservation: Reservation) {
        let coordinator = ReservationsCoordinator(reservation: reservation, router: self.router, deepLink: self.deepLink)
        self.addChildAndStart(coordinator) { (_) in}
    }

    private func startRoutineFlow() {
        let coordinator = RoutineCoordinator(router: self.router, deepLink: self.deepLink)
        self.addChildAndStart(coordinator) { (result) in }
        self.router.present(coordinator, source: self.feedVC)
    }

    private func startChannelFlow(for type: ChannelType) {
        let coordinator = ChannelCoordinator(router: self.router, deepLink: self.deepLink, channel: DisplayableChannel(channelType: type))
        self.addChildAndStart(coordinator) { (_) in
            self.router.dismiss(source: coordinator.toPresentable())
        }
        self.router.present(coordinator, source: self.feedVC)
    }

    private func showMeditation() {
        let coordinator = MeditationCoordinator(router: self.router, deepLink: self.deepLink)
        self.addChildAndStart(coordinator) { (_) in
            self.router.dismiss(source: coordinator.toPresentable())
        }
        self.router.present(coordinator, source: self.feedVC)
    }
}
