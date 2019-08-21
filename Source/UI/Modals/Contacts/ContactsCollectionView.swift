//
//  ContactsCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContactsCollectionView: CollectionView {

    lazy var emptyView = ContactsCollectionEmptyView()

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionHeadersPinToVisibleBounds = true 
        super.init(flowLayout: flowLayout)
        self.backgroundView = self.emptyView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContactsCollectionEmptyView: View {

    let button = Button()

    override func initialize() {
        self.addSubview(self.button)
        self.button.set(style: .rounded(color: .blue, text: "ADD CONTACTS"))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.button.size = CGSize(width: 200, height: Theme.buttonHeight)
        self.button.roundCorners()
        self.button.centerOnXAndY()
    }
}
