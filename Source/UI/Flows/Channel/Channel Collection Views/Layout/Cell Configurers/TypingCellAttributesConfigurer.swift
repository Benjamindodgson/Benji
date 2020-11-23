//
//  TypingCellSizeCalculator.swift
//  Benji
//
//  Created by Benji Dodgson on 9/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class TypingCellAttributesConfigurer: ChannelCellAttributesConfigurer {

    var height: CGFloat = 44

    override func size(with message: Messageable?, for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.horizontal + contentInset.horizontal
        return CGSize(width: collectionViewWidth - inset, height: self.height)
    }
}
