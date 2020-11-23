//
//  ResourceObject.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol ResourceObject: Diffable {
    var id: String { get set }
}

extension ResourceObject {
    var hashValue: Int {
        return self.diffIdentifier().hash
    }

    func diffIdentifier() -> NSObjectProtocol {
        return (self.id) as NSObjectProtocol
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
