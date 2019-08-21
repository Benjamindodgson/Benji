//
//  ChannelCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 8/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCoordinator: PresentableCoordinator<Void> {

    let channelType: ChannelType
    lazy var scrolledModal = ChannelModalViewController(with: self.channelType)

    init(router: Router, channelType: ChannelType) {
        self.channelType = channelType
        if case let .channel(channel) = channelType {
            ChannelManager.shared.selectedChannel = channel
        }
        super.init(router: router, deepLink: nil)
    }

    override func toPresentable() -> DismissableVC {
        return self.scrolledModal
    }

    override func start() {
        self.scrolledModal.didDismiss = { [unowned self] in
            self.finishFlow(with: ())
        }
    }
}
