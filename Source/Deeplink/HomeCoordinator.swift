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

    lazy var homeVC = HomeViewController(with: self)

    override func toPresentable() -> DismissableVC {
        return self.homeVC
    }

    override func start() {
        super.start()

        if PFAnonymousUtils.isLinked(with: PFUser.current()) {
            self.startLoginFlow()
        }
    }

    func startLoginFlow() {
        let coordinator = LoginCoordinator(router: self.router, userExists: false)
        self.router.present(coordinator, animated: true)
        self.addChildAndStart(coordinator, finishedHandler: { (_) in
            self.router.dismiss(animated: true, completion: nil)
        })
    }

    func startChannelFlow(for type: ChannelType) {
        let coordinator = ChannelCoordinator(router: self.router, channelType: type)
        self.router.present(coordinator, animated: true)
        self.addChildAndStart(coordinator, finishedHandler: { (_) in
            self.router.dismiss(animated: true, completion: nil)
        })
    }
}

extension HomeCoordinator: ChannelsViewControllerDelegate {
    func channelsView(_ controller: ChannelsViewController, didSelect channelType: ChannelType) {
        self.startChannelFlow(for: channelType)
    }
}
