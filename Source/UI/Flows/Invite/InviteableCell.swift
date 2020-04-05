//
//  InviteableCell.swift
//  Benji
//
//  Created by Benji Dodgson on 4/4/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class InviteableCell: UICollectionViewCell, ManageableCell {
    typealias ItemType = Inviteable

    var onLongPress: (() -> Void)?
    private let content = InviteableContentView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.intializeViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func intializeViews() {
        self.contentView.addSubview(self.content)
    }

    func configure(with item: Inviteable?) {
        guard let inviteable = item else { return }

        self.content.configure(with: inviteable)
    }

    func collectionViewManagerWillDisplay() {}
    func collectionViewManagerDidEndDisplaying() {}


    override func layoutSubviews() {
        super.layoutSubviews()

        self.content.expandToSuperviewSize()
    }
}