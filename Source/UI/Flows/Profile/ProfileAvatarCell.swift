//
//  ProfileHeaderCell.swift
//  Benji
//
//  Created by Benji Dodgson on 10/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ProfileAvatarCell: UICollectionViewCell {

    private(set) var avatarView = AvatarView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeSubViews() {
        self.contentView.addSubview(self.avatarView)
    }

    func configure(with detail: ProfileDisplayable) {
        guard let avatar = detail.avatar else { return }

        self.avatarView.showLargeImage = true
        self.avatarView.set(avatar: avatar)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.avatarView.size = CGSize(width: 110, height: 140)
        self.avatarView.top = 0
        self.avatarView.left = 0 
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.avatarView.imageView.image = nil
    }
}
