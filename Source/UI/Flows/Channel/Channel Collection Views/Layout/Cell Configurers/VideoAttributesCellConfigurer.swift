//
//  VideoAttributesCellConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 7/4/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class VideoAttributesCellConfigurer: ChannelCellAttributesConfigurer {

    override func configure(with message: Messageable, previousMessage: Messageable?, nextMessage: Messageable?, for layout: ChannelCollectionViewFlowLayout, attributes: ChannelCollectionViewLayoutAttributes) {

    }

    override func size(with message: Messageable?, for layout: ChannelCollectionViewFlowLayout) -> CGSize {
        guard let msg = message, case MessageKind.video(let item) = msg.kind else { return .zero }
        return item.size
    }
}

