//
//  UITextView+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/29/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UITextView {

    var numberOfLines: Int {
        guard let font = self.font else { return 0 }
        let numLines = (self.contentSize.height / font.lineHeight)
        return Int(numLines)
    }
}
