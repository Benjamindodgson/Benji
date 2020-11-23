//  Copyright © 2018 Tomorrow Ideas Inc. All rights reserved.

import Foundation

// IGListDiffable can only perform diffs on class objects.
// Use the DiffableBox to wrap value types, such as structs, and perform diffs on them.

protocol Diffable: Hashable {
    func diffIdentifier() -> NSObjectProtocol
}

final class DiffableBox<T: Diffable>: ListDiffable {
    let value: T
    let equal: (T, T) -> Bool

    init(value: T, equal: @escaping (T, T) -> Bool) {
        self.value = value
        self.equal = equal
    }

    public func diffIdentifier() -> NSObjectProtocol {
        return self.value.diffIdentifier()
    }

    public func isEqual(toDiffableObject obj: ListDiffable?) -> Bool {
        if let other = obj as? DiffableBox<T> {
            return equal(value, other.value)
        }
        return false
    }
}
