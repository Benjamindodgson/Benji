//
//  ChannelCellAttributesConfigurer.swift
//  Benji
//
//  Created by Benji Dodgson on 11/9/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
/// An object is responsible for
/// sizing and configuring cells for given `IndexPath`s.
class ChannelCellAttributesConfigurer {

    /// Used to configure the layout attributes for a given cell.
    ///
    /// - Parameters:
    /// - attributes: The attributes of the cell.
    /// The default does nothing
    func configure(with message: Messageable,
                   previousMessage: Messageable?,
                   nextMessage: Messageable?,
                   for layout: ChannelCollectionViewFlowLayout,
                   attributes: ChannelCollectionViewLayoutAttributes) {}

    /// Used to size an item at a given `IndexPath`.
    ///
    /// - Parameters:
    /// - indexPath: The `IndexPath` of the item to be displayed.
    /// The default return .zero
    func size(with message: Messageable?, for layout: ChannelCollectionViewFlowLayout) -> CGSize { return .zero }
}

