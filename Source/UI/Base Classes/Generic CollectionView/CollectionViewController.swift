//
//  CollectionViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CollectionViewController<CellType: ManageableCell & UICollectionViewCell,
ManagerType: CollectionViewManager<CellType>>: ViewController {

    let collectionView: CollectionView
    lazy var collectionViewManager = ManagerType(with: self.collectionView)

    init(with collectionView: CollectionView) {
        self.collectionView = collectionView
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding the collection view in viewDidLoad so that it's ensured to be the bottom most view
        self.view.addSubview(self.collectionView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.expandToSuperviewSize()
    }
}
