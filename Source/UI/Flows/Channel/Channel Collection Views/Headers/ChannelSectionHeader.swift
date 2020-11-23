//
//  ChannelSectionHeader.swift
//  Benji
//
//  Created by Benji Dodgson on 7/20/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelSectionHeader: UICollectionReusableView {

    let label = ChannelDateLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    private func initializeViews() {
        self.addSubview(self.label)
    }

    func configure(with date: Date) {
        self.label.set(date: date)
        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.setSize(withWidth: self.width)
        self.label.centerOnXAndY()
    }
}
