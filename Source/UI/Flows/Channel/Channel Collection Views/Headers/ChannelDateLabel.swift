//
//  ChannelHeaderDateLabel.swift
//  Benji
//
//  Created by Benji Dodgson on 7/20/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelDateLabel: Label {

    func set(date: Date,
             color: Color = .white,
             alignment: NSTextAlignment = .left) {

        let attributed = AttributedString(self.getString(for: date),
                                          fontType: .smallBold,
                                          color: color)
        self.set(attributed: attributed,
                 alignment: alignment,
                 lineCount: 1,
                 stringCasing: .uppercase)
    }

    private func getString(for date: Date) -> String {
        
        if date.isSameDay(as: Date.today) {
            return "Today"
        }

        let stringDate = Date.monthAndDay.string(from: date)
        return stringDate
    }
}
