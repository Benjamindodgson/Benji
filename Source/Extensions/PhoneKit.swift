//
//  PhoneKit.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import PhoneNumberKit

struct PhoneKit {
    // Phone number kit is really expensive to allocate so create a global shared instance
    static let shared = PhoneNumberKit()
    static let formatter = PartialFormatter(phoneNumberKit: PhoneKit.shared,
                                            defaultRegion: "US",
                                            withPrefix: true)
}
