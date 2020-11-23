//
//  View.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class View: UIView {

    init() {
        super.init(frame: .zero)
        self.initializeSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeSubviews()
    }

    func initializeSubviews() { }

    func showShadow(withOffset offset: CGFloat, color: UIColor = .black) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: offset)
        self.layer.shadowRadius = 10
        self.layer.masksToBounds = false
    }
}
