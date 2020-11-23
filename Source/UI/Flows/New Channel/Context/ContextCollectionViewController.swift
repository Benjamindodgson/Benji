//
//  ContextCollectionViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 4/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContextCollectionViewController: CollectionViewController<ContextCell, ContextCollectionViewManager> {
    init() {
        super.init(with: ContextCollectionView())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionViewManager.set(newItems: ConversationContext.allCases) { (_) in }
    }
}
