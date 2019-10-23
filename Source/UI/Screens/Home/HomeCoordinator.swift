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

        UserNotificationManager.shared.requestAuthorization()
    }
}

extension HomeCoordinator: HomeViewControllerDelegate {

    func homeView(_ controller: HomeViewController, didSelect option: HomeOptionType) {
        switch option {
        case .profile:
            self.presentProfile()
        case .add:
            self.presentNewChannel()
        }
    }

    private func presentProfile() {
        let coordinator = ProfileCoordinator(with: PFUser.current()!, router: self.router, deepLink: self.deepLink)
        self.present(coordinator: coordinator)
    }

    private func presentNewChannel() {
        let coordinator = NewChannelCoordinator(router: self.router, deepLink: self.deepLink)
        self.present(coordinator: coordinator)
    }

    private func present(coordinator: PresentableCoordinator<Void>) {
        self.addChildAndStart(coordinator, finishedHandler: { _ in
            self.router.dismiss(source: coordinator.toPresentable())
        })
        self.router.present(coordinator, source: self.homeVC, animated: true)
    }
}

extension HomeCoordinator: ChannelsViewControllerDelegate {

    func channelsView(_ controller: ChannelsViewController, didSelect channelType: ChannelType) {
        self.startChannelFlow(for: channelType)
    }

    func startChannelFlow(for type: ChannelType) {

        let coordinator = ChannelCoordinator(router: self.router, channelType: type)
        self.addChildAndStart(coordinator, finishedHandler: { (_) in
            self.router.dismiss(source: coordinator.toPresentable())
        })
        self.router.present(coordinator, source: self.homeVC, animated: true)
    }
}
