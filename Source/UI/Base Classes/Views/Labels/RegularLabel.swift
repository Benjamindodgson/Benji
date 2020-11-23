//
//  RegularSemiBoldLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class RegularLabel: Label {

    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left,
             stringCasing: StringCasing = .lowercase) {

        let attributed = AttributedString(text,
                                          fontType: .regular,
                                          color: color)

        self.set(attributed: attributed,
                 alignment: alignment,
                 stringCasing: stringCasing)
    }
}
