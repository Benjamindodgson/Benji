//
//  DisplayableChannel.swift
//  Benji
//
//  Created by Benji Dodgson on 10/6/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Range: Comparable {
    public static func < (lhs: Range<Bound>, rhs: Range<Bound>) -> Bool {
        return lhs.lowerBound < rhs.lowerBound
    }
}

class DisplayableChannel: ManageableCellItem, Hashable, Comparable {

    var highlightText = String()
    var highlightRange: Range<String.Index>? {
        return self.channelType.uniqueName.range(of: self.highlightText)
    }
    var channelType: ChannelType

    init(channelType: ChannelType) {
        self.channelType = channelType
    }

    var id: String {
        self.channelType.id
    }

    var isFromCurrentUser: Bool {
        return self.channelType.isFromCurrentUser
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self.channelType.diffIdentifier()
    }

    static func == (lhs: DisplayableChannel, rhs: DisplayableChannel) -> Bool {
        return lhs.channelType.uniqueName == rhs.channelType.uniqueName &&
            lhs.highlightText == rhs.highlightText
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.channelType.uniqueName)
    }

    static func < (lhs: DisplayableChannel, rhs: DisplayableChannel) -> Bool {
        if let lhsRange = lhs.highlightRange, let rhsRange = rhs.highlightRange {
            return lhsRange < rhsRange
        }
        return false
    }
}
