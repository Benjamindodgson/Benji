//
//  Optional+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 4/20/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Optional {

    var isNil: Bool {
        return self == nil ? true : false
    }

    var exists: Bool {
        return self == nil ? false: true
    }
}
