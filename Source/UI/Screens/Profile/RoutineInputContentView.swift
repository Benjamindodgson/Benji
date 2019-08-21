//
//  RoutineInputContentView.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RoutineInputContentView: View {

    let timePicker = UIDatePicker()
    let setRoutineButton = Button()

    override func initialize() {
        self.addSubview(self.timePicker)
        self.timePicker.datePickerMode = UIDatePicker.Mode.time
        self.timePicker.minuteInterval = 30
        self.timePicker.setValue(Color.white.color, forKey: "textColor")

        self.addSubview(self.setRoutineButton)
        self.setRoutineButton.set(style: .rounded(color: Color.blue,
                                                  text: "Set Routine"),
                                  shouldRound: true,
                                  casingType: StringCasing.uppercase)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.timePicker.frame = self.bounds
        self.timePicker.height = 200

        self.setRoutineButton.frame = CGRect(x: 0,
                                             y: self.timePicker.bottom,
                                             width: self.width,
                                             height: 40)
    }
}
