//
//  Character+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Character {
    var isEmoji: Bool {
        for scalar in self.unicodeScalars {

            switch scalar.value {
            case 0x1F600...0x1F64F:
                // Emoticons
                return true
            case 0x1F300...0x1F5FF:
                // Misc Symbols and Pictographs
                return true
            case 0x1F680...0x1F6FF:
                // Transport and Map
                return true
            case 0x2600...0x26FF:
                // Misc symbols, not all emoji
                return true
            case 0x2700...0x27BF:
                // Dingbats, not all emoji
                return true
            default:
                break
            }
        }

        return false
    }
}
