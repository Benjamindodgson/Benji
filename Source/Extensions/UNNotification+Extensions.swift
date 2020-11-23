//
//  UNNotification+Extension.swift
//  Benji
//
//  Created by Benji Dodgson on 4/19/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UNNotification {

    var deepLinkTarget: DeepLinkTarget? {
        return self.request.content.deepLinkTarget
    }

    var deeplinkURL: URL? {
        return self.request.content.deeplinkURL
    }

    var customMetadata: NSMutableDictionary {
        guard let data = self.request.content.userInfo["data"] as? [String: Any] else { return [:] }
        return NSMutableDictionary(dictionary: data)
    }
}
