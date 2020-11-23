//
//  XSmallLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 7/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class SmallBoldLabel: Label {
    
    func set(text: Localized,
             color: Color = .white,
             alignment: NSTextAlignment = .left,
             lineBreakMode: NSLineBreakMode = .byWordWrapping,
             stringCasing: StringCasing = .unchanged) {
        
        let attributed = AttributedString(text,
                                          fontType: .smallBold,
                                          color: color)
        self.set(attributed: attributed,
                 alignment: alignment,
                 lineBreakMode: lineBreakMode,
                 stringCasing: .unchanged)
    }
}
