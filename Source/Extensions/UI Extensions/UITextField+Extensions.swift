//
//  UITextField+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/31/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UITextField {

    func setDefaultAttributes(style: StringStyle, alignment: NSTextAlignment = .left) {
        self.defaultTextAttributes = style.attributes
        self.textAlignment = alignment
    }

    func setPlaceholder(attributed: AttributedString, alignment: NSTextAlignment = .left) {
        self.attributedPlaceholder = attributed.string
        self.textAlignment = alignment
    }

    @discardableResult func setBottomBorder(color: Color, height: CGFloat = 2.0) -> CALayer {
        let border = CALayer()
        let width = height
        border.borderColor = color.color.cgColor
        border.frame = CGRect(x: 0,
                              y: self.frame.size.height - width,
                              width: self.frame.size.width,
                              height: self.frame.size.height)

        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true

        return border
    }
}

