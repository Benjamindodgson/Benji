//
//  ChannelCellContentView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCellContentView: View {

    let moreButton = Button()

    private let contextCircle = View()
    private let headerView = View()
    private let contextLabel = Label()
    private let messageLabel = Label()
    private let avatarView = AvatarView()

    var contextText: Localized? {
        didSet {
            guard let text = self.contextText else { return }
            let attributed = AttributedString(text,
                                              color: .white)
            self.contextLabel.set(attributed: attributed)
        }
    }

    var messageText: Localized? {
        didSet {
            guard let text = self.messageText else { return }
            let attributed = AttributedString(text,
                                              color: .white)
            self.messageLabel.set(attributed: attributed)
        }
    }

    override func initialize() {

        self.addSubview(self.headerView)
        self.headerView.set(backgroundColor: .background2)
        self.headerView.addSubview(self.moreButton)
        self.moreButton.set(style: .normal(color: .clear, text: "MORE"))
        self.headerView.addSubview(self.contextCircle)
        self.contextCircle.makeRound()
        self.addSubview(self.avatarView)
        self.headerView.addSubview(self.contextLabel)
        self.addSubview(self.messageLabel)
        self.roundCorners()
        self.set(backgroundColor: .background3)
    }

    func configure(with type: ChannelType) {

        switch type {
        case .system(let message):
            self.contextCircle.layer.borderColor = message.context.color.color.cgColor
            self.contextCircle.layer.borderWidth = 2
            self.avatarView.set(avatar: message.avatar)
            self.contextText = message.context.text
            self.messageText = message.body
        case .channel(let channel):
            
            guard let channelMessages = channel.messages else { return }
            channelMessages.getLastWithCount(10, completion: { (result, messages) in
                guard let msgs = messages, let last = msgs.last else { return }

                self.messageText = last.body
                self.layoutNow()
            })
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.headerView.size = CGSize(width: self.width, height: 60)
        self.headerView.centerOnX()
        self.headerView.top = 0

        self.contextCircle.size = CGSize(width: 25, height: 25)
        self.contextCircle.left = Theme.contentOffset
        self.contextCircle.centerOnY()
        self.contextCircle.makeRound()

        self.moreButton.size = CGSize(width: 60, height: self.headerView.height)
        self.moreButton.right = self.width - Theme.contentOffset
        self.moreButton.centerOnY()

        self.contextLabel.size = CGSize(width: 200, height: self.headerView.height)
        self.contextLabel.left = self.contextCircle.right + Theme.contentOffset
        self.contextLabel.centerOnY()

        self.avatarView.size = CGSize(width: 56, height: 56)
        self.avatarView.top = self.headerView.bottom + 16
        self.avatarView.left = 16

        if let attributedText = self.messageLabel.attributedText {
            let maxWidth = self.width - self.avatarView.right - 40
            self.messageLabel.size = attributedText.getSize(withWidth: maxWidth)
            self.messageLabel.top = self.avatarView.top
            self.messageLabel.left = self.avatarView.right + 16
        }
    }
}
