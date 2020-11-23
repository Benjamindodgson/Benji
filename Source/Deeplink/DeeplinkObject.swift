//
//  DeeplinkObject.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

struct DeepLinkObject: DeepLinkable {

    var customMetadata = NSMutableDictionary()
    var deepLinkTarget: DeepLinkTarget?

    init(target: DeepLinkTarget?) {
        self.deepLinkTarget = target
    }
}
