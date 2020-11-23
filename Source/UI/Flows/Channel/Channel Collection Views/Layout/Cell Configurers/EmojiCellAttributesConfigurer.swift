//
//  EmojiCellAttributesConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 7/4/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class EmojiCellAttributesConfigurer: ChannelCellAttributesConfigurer {

    private let widthRatio: CGFloat = 0.8
    var avatarSize = CGSize(width: 30, height: 36)
    
    override func configure(with message: Messageable, previousMessage: Messageable?, nextMessage: Messageable?, for layout: ChannelCollectionViewFlowLayout, attributes: ChannelCollectionViewLayoutAttributes) {

    }

    override func size(with message: Messageable?, for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        guard let msg = message, case MessageKind.emoji(let emoji) = msg.kind else { return .zero }
        return self.getSize(for: emoji, for: layout)
    }

    private func getSize(for emoji: String, for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        let attributed = AttributedString(emoji,
                                          fontType: .regularBold,
                                          color: .white)

        let attributedString = attributed.string
        attributedString.linkItems()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: style])
        let maxWidth = (layout.itemWidth * self.widthRatio) - self.getAvatarPadding(for: layout) - self.avatarSize.width
        let size = attributedString.getSize(withWidth: maxWidth)
        return size
    }

    private func getAvatarPadding(for layout: ChannelCollectionViewFlowLayout) -> CGFloat {
        guard let dataSource = layout.dataSource else { return .zero }
        return dataSource.numberOfMembers > 2 ? .zero : 8
    }
}
