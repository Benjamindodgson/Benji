//
//  ChannelIntroHeaderAttributesConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 5/25/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelIntroHeaderAttributesConfigurer: ChannelHeaderAttributesConfigurer {

    override func sizeForHeader(at section: Int, for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        guard let collectionView = layout.collectionView else { return .zero }
        return CGSize(width: collectionView.width, height: collectionView.height - 120)
    }
}
