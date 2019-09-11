//
//  PurposeTitleLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 9/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class PurposeTitleTextField: TextField {

    let label = RegularSemiBoldLabel()
    let padding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 10)

    override func initialize() {
        super.initialize()

        self.addSubview(self.label)
        self.label.set(text: "#", color: .lightPurple, alignment: .left)

        self.returnKeyType = .done
        self.autocapitalizationType = .none

        let attributed = AttributedString("Name", fontType: .medium, color: .lightPurple)
        self.setPlaceholder(attributed: attributed)
        self.setDefaultAttributes(style: StringStyle(font: .medium, color: .lightPurple))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.setSize(withWidth: self.width)
        self.label.centerOnY()
        self.label.left = 10
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
}