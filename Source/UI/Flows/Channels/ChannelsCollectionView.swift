//
//  ChannelsCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelsCollectionView: CollectionView {

    init() {
        let flowLayout = BouncyCollectionViewLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 16, right: 0)
        super.init(layout: flowLayout)

        self.bounces = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func initializeViews() {
        super.initializeViews()

        self.register(ReservationsFooter.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
    }
}
