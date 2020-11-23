//
//  BubbleCircle.swift
//  Benji
//
//  Created by Benji Dodgson on 9/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// A `UIView` subclass that maintains a mask to keep it fully circular
class BubbleCircleView: UIView {

    /// Lays out subviews and applys a circular mask to the layer
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeRound()
    }
}

