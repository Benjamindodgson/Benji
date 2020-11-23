//
//  CGSize+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 1/18/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension CGSize {
    var cgPoint: CGPoint {
        return CGPoint(x: self.width, y: self.height)
    }
}
