//
//  Routine.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class Routine {

    var timeComponents: DateComponents
    var timeDescription: String {
        let hour = self.timeComponents.hour ?? 0
        let minute = self.timeComponents.minute ?? 0
        return "\(hour):\(minute)"
    }

    init(messageCheckTime: Date) {
        self.timeComponents = Calendar.current.dateComponents([.hour, .minute],
                                                              from: messageCheckTime)
    }

    init(timeComponents: DateComponents) {
        self.timeComponents = timeComponents
    }
}
