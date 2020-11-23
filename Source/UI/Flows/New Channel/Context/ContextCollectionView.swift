//
//  ContextCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 4/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContextCollectionView: CollectionView {

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        super.init(layout: flowLayout)

        self.contentInset = UIEdgeInsets(top: Theme.contentOffset * 2,
                                         left: Theme.contentOffset,
                                         bottom: Theme.contentOffset,
                                         right: Theme.contentOffset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
