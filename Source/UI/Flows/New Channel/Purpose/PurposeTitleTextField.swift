//
//  PurposeTitleLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 9/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class PurposeTitleTextField: TextField {

    override func initialize() {
        super.initialize()

        self.padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        self.returnKeyType = .done
        self.autocapitalizationType = .none
        self.autocorrectionType = .no

        let attributed = AttributedString("name", fontType: .display, color: .background4)
        self.setPlaceholder(attributed: attributed)
        self.setDefaultAttributes(style: StringStyle(font: .displayUnderlined, color: .white))
    }

    func updateColor(for context: ConversationContext) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.setDefaultAttributes(style: StringStyle(font: .displayUnderlined, color: context.color))
        }
    }
}
