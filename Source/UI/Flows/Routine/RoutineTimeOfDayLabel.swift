//
//  RoutineTimeOfDayLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 12/1/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RoutineTimeOfDayLabel: SmallLabel {

    func set(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        let string = formatter.string(from: date)
        self.set(text: string,
                 color: .lightPurple,
                 alignment: .left,
                 stringCasing: .uppercase)
    }
}
