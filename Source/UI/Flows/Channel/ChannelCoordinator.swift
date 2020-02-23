//
//  ChannelCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 8/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class ChannelCoordinator: PresentableCoordinator<Void> {

    let channelType: ChannelType
    lazy var channelVC = ChannelViewController(channelType: self.channelType, delegate: self)

    init(router: Router, channelType: ChannelType) {
        self.channelType = channelType
        if case let .channel(channel) = channelType {
            ChannelManager.shared.activeChannel.value = channel
        }
        super.init(router: router, deepLink: nil)
    }

    override func toPresentable() -> DismissableVC {
        return self.channelVC
    }
}

extension ChannelCoordinator: ChannelDetailBarDelegate {

    func channelDetailBarDidTapMenu(_ view: ChannelDetailBar) {
        //Present channel menu
    }
}

extension ChannelCoordinator: ChannelViewControllerDelegate {

    func channelView(_ controller: ChannelViewController, didTapShare message: Messageable) {
        let items = [localized(message.text)]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.present(ac, animated: true, completion: nil)
    }
}
