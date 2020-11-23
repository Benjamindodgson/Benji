//
//  TextSuggestionCellAttributesConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class TextSuggestionCellAttributesConfigurer: SuggestionCellAttributesConfigurer {

    override func configure(with suggestion: SuggestionType,
                            for layout: SuggestionCollectionViewFlowLayout,
                            attributes: SuggestionCollectionViewLayoutAttributes) {
        
    }

    override func size(with suggestion: SuggestionType?,
                       for layout: SuggestionCollectionViewFlowLayout) -> CGSize {
        return .zero
    }
}
