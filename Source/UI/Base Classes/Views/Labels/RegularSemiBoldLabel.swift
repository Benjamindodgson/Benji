//
//  RegularSemiBoldLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RegularSemiBoldLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left,
             stringCasing: StringCasing = .lowercase) {

        let attributed = AttributedString(text,
                                          fontType: .regularSemiBold,
                                          color: color)

        self.set(attributed: attributed,
                 alignment: alignment,
                 stringCasing: .lowercase)
    }
}
