//
//  CloseButton.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CloseButton: Button {

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.size = CGSize(width: 25, height: 25)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.makeRound()
        self.layer.borderColor = Color.white.color.cgColor
        self.layer.borderWidth = 2
    }
}
