//
//  ChannelCellContentView.swift
//  Benji
//
//  Created by Benji Dodgson on 1/5/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCellContentView: ChannelContentView {

    override func initializeSubviews() {
        super.initializeSubviews()
        
        self.roundCorners()
    }

    func highlight(text: String) {
        guard let attributedText = self.titleLabel.attributedText, attributedText.string.contains(text) else { return }

        let newString = NSMutableAttributedString(attributedString: attributedText)

        if let range = attributedText.string.range(of: text) {
            let nsRange = text.nsRange(from: range)
            newString.addAttributes([NSAttributedString.Key.foregroundColor: Color.lightPurple.color], range: nsRange)
        }

        self.titleLabel.attributedText = newString
        self.layoutNow()
    }
}
