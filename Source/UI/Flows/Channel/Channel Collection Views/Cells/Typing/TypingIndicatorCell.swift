//
//  TypingIndicatorCell.swift
//  Benji
//
//  Created by Benji Dodgson on 9/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// A subclass of `MessageCollectionViewCell` used to display the typing indicator.
class TypingIndicatorCell: UICollectionViewCell {

    // MARK: - Subviews

    private let typingBubble = TypingBubbleView()
    private let avatarView = AvatarView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    func initializeViews() {
        self.addSubview(self.avatarView)
        self.addSubview(self.typingBubble)
    }

    func configure(with avatar: Avatar) {
        self.avatarView.set(avatar: avatar)
    }

    func startAnimating() {
        self.typingBubble.startAnimating()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        if self.typingBubble.isAnimating {
            self.typingBubble.stopAnimating()
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        self.avatarView.setSize(for: 36)
        self.avatarView.left = Theme.contentOffset

        let insets = UIEdgeInsets(top: 4, left: self.avatarView.right + 4, bottom: 2, right: 0)
        self.typingBubble.frame = self.bounds.inset(by: insets)

        self.avatarView.bottom = self.typingBubble.bottom
    }
}
