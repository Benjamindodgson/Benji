//
//  BaseMessageCell.swift
//  Benji
//
//  Created by Benji Dodgson on 7/4/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Lottie

class BaseMessageCell: UICollectionViewCell {

    let avatarView = AvatarView()
    var didTapMessage: () -> Void = {}

    private(set) var currentMessage: Messageable?
    private(set) var attributes: ChannelCollectionViewLayoutAttributes?
    private var animationView = AnimationView(name: "error")

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

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let attributes = layoutAttributes as? ChannelCollectionViewLayoutAttributes else { return }
        self.attributes = attributes
        self.layoutContent(with: attributes)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.currentMessage = nil
        self.attributes = nil
        self.animationView.alpha = 0
    }

    // OVERRIDES

    func initializeViews() {

        self.contentView.addSubview(self.animationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop

        self.contentView.addSubview(self.avatarView)
    }

    func configure(with message: Messageable) {
        self.currentMessage = message
        if !message.isFromCurrentUser {
            self.avatarView.set(avatar: message.avatar)
        }

        self.handleIsConsumed(for: message)
        self.handleStatus(for: message)
    }

    func showError() {
        self.animationView.forceDisplayUpdate()

        UIView.animate(withDuration: 0.2) {
            self.animationView.alpha = 1
        }

        self.animationView.play()
    }

    func handleIsConsumed(for message: Messageable) {

    }

    func layoutContent(with attributes: ChannelCollectionViewLayoutAttributes) {
        self.avatarView.frame = attributes.attributes.avatarFrame
        self.animationView.size = CGSize(width: 22, height: 22)
    }

    // PRIVATE

    private func handleStatus(for message: Messageable) {
        self.animationView.alpha = 0

        if message.isFromCurrentUser {
            switch message.status {
            case .error:
                self.showError()
            default:
                break
            }
        }
    }
}

class MessageBubbleView: View {
    var indexPath: IndexPath?
}
