//
//  RoutineTimeLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 12/1/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RoutineTimeLabel: Label {

    func set(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let dateString = formatter.string(from: date)

        let attributed = AttributedString(dateString,
                                          fontType: .displayThin,
                                          color: .lightPurple)
        let string = StringCasing.uppercase.format(string: attributed.string.string)
        let newString = NSMutableAttributedString(string: string)
        newString.addAttributes(attributed.attributes, range: NSRange(location: 0,
                                                                      length: newString.length))

        self.attributedText = newString
    }
}
