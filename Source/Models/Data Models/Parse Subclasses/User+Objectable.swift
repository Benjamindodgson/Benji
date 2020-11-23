//
//  User+Objectable.swift
//  Benji
//
//  Created by Benji Dodgson on 11/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

extension User: Objectable {
    typealias KeyType = UserKey

    func getObject<Type>(for key: UserKey) -> Type? {
        return self.object(forKey: key.rawValue) as? Type
    }

    func setObject<Type>(for key: UserKey, with newValue: Type) {
        self.setObject(newValue, forKey: key.rawValue)
    }

    func getRelationalObject<PFRelation>(for key: UserKey) -> PFRelation? {
        return self.relation(forKey: key.rawValue) as? PFRelation
    }
}
