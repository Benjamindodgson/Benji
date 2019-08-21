//
//  ChannelModalViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelModalViewController: ScrolledModalViewController<ChannelViewController> {

    let detailBar = ChannelDetailBar()

    init(with channelType: ChannelType) {
        super.init(presentable: ChannelViewController(channelType: channelType))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()
        
        self.tapDismissView.set(backgroundColor: .background1)
        self.view.addSubview(self.detailBar)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.detailBar.size = CGSize(width: self.view.width, height: 60)
        self.detailBar.bottom = self.modalContainerView.top 
        self.detailBar.centerOnX()
    }
}
