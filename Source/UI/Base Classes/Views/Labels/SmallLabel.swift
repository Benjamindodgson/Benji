//
//  SmallSemiBoldLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 9/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class SmallLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left,
             lineBreakMode: NSLineBreakMode = .byWordWrapping,
             stringCasing: StringCasing = .unchanged) {

        let attributed = AttributedString(text,
                                          fontType: .small,
                                          color: color)
        self.set(attributed: attributed,
                 alignment: alignment,
                 lineBreakMode: lineBreakMode,
                 stringCasing: stringCasing)
    }
}
