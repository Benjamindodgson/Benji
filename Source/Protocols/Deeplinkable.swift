//
//  Deeplinkable.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol DeepLinkable {
    var customMetadata: NSMutableDictionary { get set }
    var deepLinkTarget: DeepLinkTarget? { get set }
    var channelId: String? { get set }
    var reservationId: String? { get set }
    var reservationCreatorId: String? { get set }
}

extension DeepLinkable {
    subscript(key: String) -> Any? {
      get {
        return self.customMetadata[key]
      }

      set (newValue) {
        self.customMetadata[key] = newValue
      }
    }
}

extension DeepLinkable {

    var channelId: String? {
        get {
            return self.customMetadata.value(forKey: "channeId") as? String
        }
        set {
            self.customMetadata.setValue(newValue, forKey: "channelId")
        }
    }

    var reservationId: String? {
        get {
            return self.customMetadata.value(forKey: ReservationKey.reservationId.rawValue) as? String
        }
        set {
            self.customMetadata.setValue(newValue, forKey: ReservationKey.reservationId.rawValue)
        }
    }

    var reservationCreatorId: String? {
        get {
            return self.customMetadata.value(forKey: ReservationKey.createdBy.rawValue) as? String
        }
        set {
            self.customMetadata.setValue(newValue, forKey: ReservationKey.createdBy.rawValue)
        }
    }
}
