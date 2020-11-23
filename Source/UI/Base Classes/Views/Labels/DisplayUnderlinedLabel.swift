//
//  DisplayUnderlinedLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 4/7/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class DisplayUnderlinedLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left,
             stringCasing: StringCasing = .unchanged) {

        let attributed = AttributedString(text,
                                          fontType: .displayUnderlined,
                                          color: color)

        self.set(attributed: attributed,
                 alignment: alignment,
                 stringCasing: stringCasing)
    }
}
