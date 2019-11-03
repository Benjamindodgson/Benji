//
//  PFObject+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 9/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

protocol Subclassing: PFSubclassing {}

extension Subclassing {
    static func parseClassName() -> String {
        return String(describing: self)
    }
}

protocol Objectable: class {
    associatedtype KeyType

    func getObject<Type>(for key: KeyType) -> Type?
    func getRelationalObject<PFRelation>(for key: KeyType) -> PFRelation?
    func setObject<Type>(for key: KeyType, with newValue: Type)
    func saveObject() -> Future<Self>

    static func cachedQuery(for objectID: String) -> Future<Self>
    static func cachedArrayQuery(with identifiers: [String]) -> Future<[Self]>
    static func cachedArrayQuery(notEqualTo identifier: String) -> Future<[Self]>
}

extension Objectable {

    static func cachedQuery(for objectID: String) -> Future<Self> {
        return Promise<Self>()
    }

    static func cachedArrayQuery(with identifiers: [String]) -> Future<[Self]> {
        return Promise<[Self]>()
    }

    static func cachedArrayQuery(notEqualTo identifier: String) -> Future<[Self]> {
        return Promise<[Self]>()
    }
}
