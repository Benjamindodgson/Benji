//
//  Display2Label.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class DisplayThinLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left) {
        let attributed = AttributedString(text,
                                          fontType: .displayThin,
                                          color: color)

        self.set(attributed: attributed,
                 alignment: alignment,
                 stringCasing: .capitalized)
    }
}
