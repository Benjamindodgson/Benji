//
//  AttachementCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/29/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class AttachmentCollectionView: CollectionView {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        super.init(layout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.bounces = false
        self.set(backgroundColor: .clear)
        self.showsHorizontalScrollIndicator = false

        self.register(AttachementHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    }
}
