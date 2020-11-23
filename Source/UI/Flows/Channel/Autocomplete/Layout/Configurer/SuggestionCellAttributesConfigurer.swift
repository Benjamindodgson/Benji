//
//  SuggestionCellAttributesConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation


/// An object is responsible for
/// sizing and configuring cells for given `IndexPath`s.
class SuggestionCellAttributesConfigurer {

    /// Used to configure the layout attributes for a given cell.
    ///
    /// - Parameters:
    /// - attributes: The attributes of the cell.
    /// The default does nothing
    func configure(with suggestion: SuggestionType,
                   for layout: SuggestionCollectionViewFlowLayout,
                   attributes: SuggestionCollectionViewLayoutAttributes) {}

    /// Used to size an item at a given `IndexPath`.
    ///
    /// - Parameters:
    /// - indexPath: The `IndexPath` of the item to be displayed.
    /// The default return .zero
    func size(with suggestion: SuggestionType?, for layout: SuggestionCollectionViewFlowLayout) -> CGSize { return .zero }
}
