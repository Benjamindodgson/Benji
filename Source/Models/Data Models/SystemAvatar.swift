//
//  SystemAvatar.swift
//  Benji
//
//  Created by Benji Dodgson on 6/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

struct SystemAvatar: Avatar {

    var person: Person?
    var image: UIImage?
    var handle: String?

    var givenName: String? {
        return "Benji"
    }

    var familyName: String? {
        return "Dodgson"
    }

    var userObjectID: String? {
        return nil 
    }
}
