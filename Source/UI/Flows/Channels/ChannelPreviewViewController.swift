//
//  ChannelPreviewViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 1/22/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelPreviewViewController: ViewController {

    let channel: DisplayableChannel
    let channelSize: CGSize
    private let content = ChannelContentView()

    init(with channel: DisplayableChannel, size: CGSize) {
        self.channel = channel
        self.channelSize = size
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()
        self.view.addSubview(self.content)
        self.content.configure(with: self.channel.channelType)
        self.preferredContentSize = self.channelSize
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.content.expandToSuperviewSize()
    }
}
