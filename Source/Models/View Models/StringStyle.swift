//
//  StringStyle.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

struct StringStyle {
    var fontType: FontType
    var color: Color

    init(font: FontType = .regular,
         color: Color) {

        self.fontType = font
        self.color = color
    }

    var attributes: [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.font: self.fontType.font,
                NSAttributedString.Key.kern: self.fontType.kern,
                NSAttributedString.Key.foregroundColor: self.color.color,
                NSAttributedString.Key.underlineStyle: self.fontType.underlineStyle.rawValue,
                NSAttributedString.Key.underlineColor: self.color.color]
    }

    var rawValueAttributes: [String : Any] {
        var rawAttributes: [String : Any] = [:]

        let attributes = self.attributes
        for attribute in attributes {
            rawAttributes[attribute.key.rawValue] = attribute.value
        }
        return rawAttributes
    }
}
