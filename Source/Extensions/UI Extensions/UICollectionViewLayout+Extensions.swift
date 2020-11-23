//
//  UICollectionViewLayout+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UICollectionViewLayout {

    // returns a square itemSize based on the height and insets of the collectionView
    var defualtVerticalItemSize: CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        let size = CGSize(width: collectionView.height - collectionView.contentInset.vertical,
                          height: collectionView.height - collectionView.contentInset.vertical)
        return size
    }

    // returns a square itemSize based on the width and insets of the collectionView
    var defualtHorizontalItemSize: CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        let size = CGSize(width: collectionView.width - collectionView.contentInset.horizontal,
                          height: collectionView.width - collectionView.contentInset.horizontal)
        return size
    }
}
