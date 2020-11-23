//
//  SuggestionCollectionViewLayoutAttributes.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

struct SuggestionLayoutAttributes: Equatable {
    var textViewFrame: CGRect = .zero
}

class SuggestionCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var attributes = SuggestionLayoutAttributes()

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SuggestionCollectionViewLayoutAttributes
        copy.attributes = self.attributes
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let layoutAttributes = object as? SuggestionCollectionViewLayoutAttributes {
            return super.isEqual(object) && layoutAttributes.attributes == self.attributes
        }

        return false
    }
}
