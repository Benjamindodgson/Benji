//
//  BranchUniversalObject+Extension.swift
//  Benji
//
//  Created by Benji Dodgson on 11/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Branch

extension BranchUniversalObject: DeepLinkable {

    var customMetadata: NSMutableDictionary {
        get {
            return self.contentMetadata.customMetadata
        }
        set {
            self.contentMetadata.customMetadata = newValue
        }
    }

    var deepLinkTarget: DeepLinkTarget? {
        get {
            guard let targetString = self.customMetadata.value(forKey: "deeplink") as? String else {
                return nil
            }
            return DeepLinkTarget(rawValue: targetString)
        }
        set {
            let targetString = newValue?.rawValue
            self.customMetadata.setValue(targetString, forKey: "deeplink")
        }
    }
}
