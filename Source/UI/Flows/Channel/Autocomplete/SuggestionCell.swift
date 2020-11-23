//
//  SuggestionCell.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class SuggestionCell: UICollectionViewCell, ManageableCell {
    typealias ItemType = SuggestionType

    var backgroundStyle: UIKeyboardAppearance = .light
    var onLongPress: (() -> Void)?

    let label = RegularBoldLabel()

    func configure(with item: SuggestionType?) {
        guard let suggestion = item else { return }

        switch suggestion {
        case .text(let text):
            self.label.set(text: text)
        }

        self.layoutNow()
    }

    func collectionViewManagerWillDisplay() {}
    func collectionViewManagerDidEndDisplaying() {}

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.setSize(withWidth: self.contentView.width * 0.8)
        self.label.centerOnXAndY()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.contentView.scaleDown()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.contentView.scaleUp()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.contentView.scaleUp()
    }
}
