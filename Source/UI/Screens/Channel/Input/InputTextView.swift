//
//  InputTextView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/2/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class InputTextView: GrowingTextView {

    override func initialize() {
        super.initialize()

        self.set(placeholder: "Message...")

        self.textContainerInset.left = 0
        self.textContainerInset.right = 10
        self.textContainerInset.top = 14
        self.textContainerInset.bottom = 12

        self.set(backgroundColor: .clear)
    }

    func set(placeholder: Localized) {
        let styleAttributes = StringStyle(font: .regularSemiBold, color: .lightPurple).attributes
        let string = NSAttributedString(string: localized(placeholder), attributes: styleAttributes)
        self.attributedPlaceholder = string
    }
}
