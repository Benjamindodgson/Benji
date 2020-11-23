//
//  AnyHashableDisplayable.swift
//  Benji
//
//  Created by Benji Dodgson on 12/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// An object that is both hashable and a displayable item.
typealias HashableDisplayable = Hashable & Avatar

/// A type erased wrapper around a DisplayableItem. This allows displayable items to be treated as hashables.
/// Equatable structs  with AnyHashableDisplayable vars can autosynthesize their "==" function.
struct AnyHashableDisplayable {

    var value: Avatar {
        // The contained item is guaranteed to be displayable because of the init's type constraints.
        return self.hashable.base as! Avatar
    }

    fileprivate let hashable: AnyHashable

    init<T: HashableDisplayable>(_ displayable: T) {
        self.hashable = AnyHashable(displayable)
    }
}

extension AnyHashableDisplayable: Hashable {
    static func ==(lhs: AnyHashableDisplayable, rhs: AnyHashableDisplayable) -> Bool {
        return lhs.hashable == rhs.hashable
    }

    func hash(into hasher: inout Hasher) {
        self.hashable.hash(into: &hasher)
    }
}
