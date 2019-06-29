//
//  HomeSegmentControl.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class HomeSegmentControl: UISegmentedControl {

    override init(items: [Any]?) {
        super.init(items: items)
        self.initialize()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        self.tintColor = Color.purple.color
    }
}
