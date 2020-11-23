//
//  ChannelCell.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

class ChannelCell: UICollectionViewCell, ManageableCell {
    typealias ItemType = DisplayableChannel

    var onLongPress: (() -> Void)?
    let content = ChannelCellContentView()
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initializeViews() {
        self.contentView.addSubview(self.content)
    }

    func configure(with item: DisplayableChannel?) {
        guard let displayable = item else { return }

        self.content.configure(with: displayable.channelType)
    }

    func collectionViewManagerWillDisplay() {}
    func collectionViewManagerDidEndDisplaying() {}

    override func prepareForReuse() {
        super.prepareForReuse()

        self.content.reset()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.content.size = CGSize(width: self.contentView.width - (16 * 2), height: self.contentView.height)
        self.content.centerOnXAndY()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.selectionFeedback.impactOccurred()
        self.scaleDown()
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.scaleUp()
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.scaleUp()
    }
}
