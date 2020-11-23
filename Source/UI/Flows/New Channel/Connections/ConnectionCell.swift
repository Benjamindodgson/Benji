//
//  ConnectionCell.swift
//  Benji
//
//  Created by Benji Dodgson on 4/5/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ConnectionCell: UICollectionViewCell, ManageableCell {
    typealias ItemType = Connection

    var onLongPress: (() -> Void)?
    private let content = ConnectionContentView()
    private var connection: Connection?

    var showSelected: Bool? {
        didSet {
            guard let showSelected = self.showSelected, showSelected != oldValue else { return }

            if showSelected {
                self.content.animateToChecked()
            } else {
                self.content.animateToUnchecked()
            }
        }
    }

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

    func configure(with item: Connection?) {
        guard let connection = item else { return }
        self.connection = connection
        self.content.configure(with: connection)
        self.layoutNow()
    }

    func update(isSelected: Bool) {
        self.showSelected = isSelected
    }

    func collectionViewManagerWillDisplay() {
        guard let connection = self.connection else { return }
        self.content.configure(with: connection)
        self.layoutNow()
    }

    func collectionViewManagerDidEndDisplaying() {}

    override func layoutSubviews() {
        super.layoutSubviews()

        self.content.expandToSuperviewSize()
    }
}
