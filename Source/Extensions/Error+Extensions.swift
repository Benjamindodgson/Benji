//
//  Error+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 4/27/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
