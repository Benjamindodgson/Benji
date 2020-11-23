//
//  UIEdgeInsets+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 9/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIEdgeInsets {

    var vertical: CGFloat {
        return self.top + self.bottom
    }

    var horizontal: CGFloat {
        return self.left + self.right
    }
}
