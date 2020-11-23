//
//  SystemChannel.swift
//  Benji
//
//  Created by Benji Dodgson on 9/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

struct SystemChannel: Diffable, Hashable {

    var avatars: [Avatar]
    var context: MessageContext
    var id: String
    var timeStampAsDate: Date
    var messages: [SystemMessage]
    var uniqueName: String

    var displayName: String {
        return self.uniqueName
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSObjectProtocol
    }

    static func == (lhs: SystemChannel, rhs: SystemChannel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
