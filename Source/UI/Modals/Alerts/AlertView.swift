//
//  AlertView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class AlertView: View {

    private(set) var containerView = UIView()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .background3)
        self.addSubview(self.containerView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.showShadow(withOffset: 5)
    }
}
