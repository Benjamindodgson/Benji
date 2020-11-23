//
//  Display1Label.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class DisplayLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left,
             stringCasing: StringCasing = .unchanged) {

        let attributed = AttributedString(text,
                                          fontType: .display,
                                          color: color)

        self.set(attributed: attributed,
                 alignment: alignment,
                 stringCasing: stringCasing)
    }
}
