//
//  ChannelCell.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

class MessageCell: UICollectionViewCell {

    let avatarView = AvatarView()
    let bubbleView = View()
    let textView = MessageTextView()
    let overlayView = View()
    var didTapMessage: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.initializeViews()
    }

    private func initializeViews() {

        self.contentView.addSubview(self.avatarView)
        self.contentView.addSubview(self.bubbleView)
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.overlayView)
        self.overlayView.set(backgroundColor: .clear)

        let view = UIView(frame: self.bounds)
        view.set(backgroundColor: .clear)
        self.backgroundView = view
        self.selectedBackgroundView = view

        //TODO: REMOVE SELECTED STATE FROM CELL 

        self.overlayView.onTap { [unowned self] (tap) in
            self.didTapMessage()
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let attributes = layoutAttributes as? ChannelCollectionViewLayoutAttributes else { return }

        self.layoutContent(with: attributes)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.bubbleView.layer.borderColor = nil
        self.bubbleView.layer.borderWidth = 0
        
        self.textView.text = nil
    }

    func configure(with message: Messageable) {

        if !message.isFromCurrentUser {
            self.avatarView.set(avatar: message.avatar)
        }
        self.textView.set(text: message.text, messageContext: message.context)

        self.handleStatus(for: message)
        self.handleIsConsumed(for: message)
    }

    private func handleStatus(for message: Messageable) {

        if message.isFromCurrentUser {
            switch message.status {
            case .sent:
                break
            case .delivered:
                break
            case .unknown:
                break
            case .error:
                break
            }
        } else {
            switch message.status {
            case .sent:
                break
            case .delivered:
                break
            case .unknown:
                break
            case .error:
                break
            }
        }
    }

    private func handleIsConsumed(for message: Messageable) {

        self.bubbleView.set(backgroundColor: message.color)

        if !message.isFromCurrentUser, !message.isConsumed, message.context != .status {

            if !message.isFromCurrentUser, message.context == .casual {
                self.bubbleView.layer.borderColor = Color.purple.color.cgColor
            } else {
                self.bubbleView.layer.borderColor = message.context.color.color.cgColor
            }

            self.bubbleView.layer.borderWidth = 2
        }
    }

    private func layoutContent(with attributes: ChannelCollectionViewLayoutAttributes) {

        self.avatarView.frame = attributes.attributes.avatarFrame
        self.textView.frame = attributes.attributes.textViewFrame
        self.bubbleView.frame = attributes.attributes.bubbleViewFrame
        self.overlayView.frame = attributes.attributes.bubbleViewFrame
        self.bubbleView.layer.maskedCorners = attributes.attributes.maskedCorners
        self.bubbleView.roundCorners()
    }
}
