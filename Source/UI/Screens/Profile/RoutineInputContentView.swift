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

    override func initialize() {
        self.set(backgroundColor: .white)

        self.addSubview(self.timePicker)
        self.timePicker.datePickerMode = UIDatePicker.Mode.time
        self.timePicker.minuteInterval = 30
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.timePicker.frame = self.bounds
    }
}
