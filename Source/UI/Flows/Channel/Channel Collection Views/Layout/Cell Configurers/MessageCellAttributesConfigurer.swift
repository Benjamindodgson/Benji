//
//  MessageCellAttributesConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 11/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageCellAttributesConfigurer: ChannelCellAttributesConfigurer {

    var avatarSize = CGSize(width: 30, height: 36)
    var textViewVerticalPadding: CGFloat = 10
    var textViewHorizontalPadding: CGFloat = 14
    var bubbleViewHorizontalPadding: CGFloat = 14
    private let widthRatio: CGFloat = 0.8

    override func configure(with message: Messageable,
                            previousMessage: Messageable?,
                            nextMessage: Messageable?,
                            for layout: ChannelCollectionViewFlowLayout,
                            attributes: ChannelCollectionViewLayoutAttributes) {

        let textViewSize = self.getTextViewSize(with: message, for: layout)
        let bubbleViewFrame = self.getBubbleViewFrame(with: message, textViewSize: textViewSize, for: layout)
        attributes.attributes.bubbleViewFrame = bubbleViewFrame

        let avatarFrame = self.getAvatarFrame(with: message, layout: layout)
        attributes.attributes.avatarFrame = avatarFrame

        attributes.attributes.textViewFrame = self.getTextViewFrame(with: bubbleViewFrame.size, textViewSize: textViewSize)

        //Determine masked corners
        if message.isFromCurrentUser {
            if let previous = previousMessage, previous.authorID == message.authorID {
                attributes.attributes.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            } else {
                attributes.attributes.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        } else {

            if let next = nextMessage, next.authorID == message.authorID {
                attributes.attributes.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            } else {
                attributes.attributes.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
    }

    override func size(with message: Messageable?, for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        guard let msg = message else { return .zero }

        let itemHeight = self.cellContentHeight(with: msg, for: layout)
        return CGSize(width: layout.itemWidth, height: itemHeight)
    }

    // PRIVATE

    private func cellContentHeight(with message: Messageable,
                                   for layout: ChannelCollectionViewFlowLayout) -> CGFloat {
        let size = self.getTextViewSize(with: message, for: layout)
        return self.getBubbleViewFrame(with: message, textViewSize: size, for: layout).height
    }

    private func getAvatarFrame(with message: Messageable, layout: ChannelCollectionViewFlowLayout) -> CGRect {
        guard let dataSource = layout.dataSource else { return .zero }

        var size: CGSize = .zero
        if !message.isFromCurrentUser, dataSource.numberOfMembers > 2 {
            size = self.avatarSize
        }
        let xOffset: CGFloat = self.getAvatarPadding(for: layout)
        return CGRect(x: xOffset,
                      y: 0,
                      width: size.width,
                      height: size.height)
    }

    private func getTextViewFrame(with bubbleViewSize: CGSize, textViewSize: CGSize) -> CGRect {
        return CGRect(x: self.bubbleViewHorizontalPadding,
                      y: self.textViewVerticalPadding,
                      width: textViewSize.width,
                      height: textViewSize.height)
    }

    private func getBubbleViewFrame(with message: Messageable,
                                    textViewSize: CGSize,
                                    for layout: ChannelCollectionViewFlowLayout) -> CGRect {

        var xOffset: CGFloat = 0
        if message.isFromCurrentUser {
            xOffset = layout.itemWidth - textViewSize.width - (self.textViewHorizontalPadding * 2)
        } else {
            xOffset = self.getAvatarFrame(with: message, layout: layout).width + (self.getAvatarPadding(for: layout) * 2) + Theme.contentOffset
        }

        return CGRect(x: xOffset - self.bubbleViewHorizontalPadding,
                      y: 0,
                      width: textViewSize.width + (self.bubbleViewHorizontalPadding * 2),
                      height: textViewSize.height + (self.textViewVerticalPadding * 2))
    }

    private func getTextViewSize(with message: Messageable,
                                 for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        guard case MessageKind.text(let text) = message.kind else { return .zero }
        let attributed = AttributedString(text,
                                          fontType: .smallBold,
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
