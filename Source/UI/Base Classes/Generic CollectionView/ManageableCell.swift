//
//  ManageableCell.swift
//  Benji
//
//  Created by Benji Dodgson on 11/9/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol ManageableCellItem: Diffable {
    var id: String { get }
}

extension ManageableCellItem {
    /// By default the diffIdentifier is just the item's identifier.
    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSObjectProtocol
    }
}

protocol ManageableCell: class {
    /// The type that will be used to configure this object.
    associatedtype ItemType: ManageableCellItem

    static var reuseID: String { get }

    /// Triggered when a long press gesture occurs on this item.
    var onLongPress: (() -> Void)? { get set }

    /// Conforming types should take in the item type and set up the cell's visual state.
    func configure(with item: ItemType?)

    /// Called when a managing object will display this object.
    func collectionViewManagerWillDisplay()
    /// Called when a managing object will stop displaying this object.
    func collectionViewManagerDidEndDisplaying()

    /// Called with a managing objects selectedIndexPaths is set
    func update(isSelected: Bool)
}

extension ManageableCell {

    /// The reuse id that a cell manager will use to recycle the cells.
    static var reuseID: String {
        /// Use the name of the class as the reuse identifier.
        return String(describing: self)
    }

    func update(isSelected: Bool) { }
}

