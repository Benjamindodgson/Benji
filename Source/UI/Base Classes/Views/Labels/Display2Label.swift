//
//  Display2Label.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class Display2Label: Label {

    func set(text: Localized, alignment: NSTextAlignment = .left) {
        let attributed = AttributedString(text,
                                          fontType: .display2,
                                          color: .white)

        self.set(attributed: attributed,
                 alignment: alignment,
                 stringCasing: .capitalized)
    }
}
