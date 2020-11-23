//
//  MediumLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 7/27/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class MediumLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             lineBreakMode: NSLineBreakMode = .byWordWrapping,
             alignment: NSTextAlignment = .left) {

        let attributed = AttributedString(text,
                                          fontType: .medium,
                                          color: color)
        self.set(attributed: attributed,
                 alignment: alignment,
                 lineBreakMode: lineBreakMode,
                 stringCasing: .unchanged)
    }
}
