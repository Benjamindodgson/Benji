//
//  ContextCell.swift
//  Benji
//
//  Created by Benji Dodgson on 4/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class ContextCell: UICollectionViewCell, ManageableCell {
    typealias ItemType = ConversationContext

    var onLongPress: (() -> Void)?

    private let label = SmallBoldLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initializeViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeViews() {
        self.label.alpha = 0.4
        self.contentView.addSubview(self.label)
    }

    func configure(with item: ConversationContext?) {
        guard let context = item else { return }

        self.label.set(text: localized(context.title).uppercased(), color: context.color, alignment: .center)
        self.label.backgroundColor = context.color.color.withAlphaComponent(0.4)

        self.label.layer.borderColor = context.color.color.cgColor
        self.label.layer.borderWidth = 2
        self.label.roundCorners()
    }

    func collectionViewManagerWillDisplay() {}
    func collectionViewManagerDidEndDisplaying() {}

    func update(isSelected: Bool) {
        self.label.alpha = isSelected ? 1 : 0.4
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.expandToSuperviewSize()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.label.alpha = 0.4
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.label.scaleDown()
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.label.scaleUp()
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.label.scaleUp()
    }
}
