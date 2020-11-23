//
//  ChannelCollectionViewLayoutAttributes.swift
//  Benji
//
//  Created by Benji Dodgson on 7/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

struct ChannelLayoutAttributes: Equatable {
    //Header
    var headerTopOffset: CGFloat = .zero
    var headerDateOffset: CGFloat = .zero
    var headerDateLabelSize: CGSize = .zero
    var headerDescriptionLabelSize: CGSize = .zero

    //Cell
    var avatarFrame: CGRect = .zero
    var bubbleViewFrame: CGRect = .zero
    var textViewFrame: CGRect = .zero
    var maskedCorners: CACornerMask = []

    //Photo
    var imageFrame: CGRect = .zero 
}

class ChannelCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var attributes = ChannelLayoutAttributes()

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ChannelCollectionViewLayoutAttributes
        copy.attributes = self.attributes
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let layoutAttributes = object as? ChannelCollectionViewLayoutAttributes {
            return super.isEqual(object) && layoutAttributes.attributes == self.attributes
        }

        return false
    }
}
