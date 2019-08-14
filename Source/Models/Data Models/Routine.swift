//
//  Routine.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class Routine: PFObject {

    var messageCheckTime: Date

    init(messageCheckTime: Date) {
        self.messageCheckTime = messageCheckTime

        super.init(className: "Routine")
    }
}
