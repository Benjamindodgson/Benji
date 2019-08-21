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

    var handle: String {
        return "@benji"
    }
    
    var initials: String {
        return "BD"
    }

    var firstName: String {
        return "Benji"
    }

    var lastName: String {
        return "Dodgson"
    }

    var user: PFUser? {
        return nil
    }

    var userObjectID: String? {
        return nil 
    }
    
    var photo: UIImage?

}
