//
//  RoutineInputViewController.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RoutineInputViewController: ViewController {

    let content = RoutineInputContentView()

    override func loadView() {
        self.view = self.content
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.content.timePicker.addTarget(self,
                                          action: #selector(self.onTimeChanged),
                                          for: .valueChanged)
    }

    @objc func onTimeChanged(datePicker: UIDatePicker) {

        let date = datePicker.date.addingTimeInterval(60)
        let routine = Routine(messageCheckTime: date)
        RoutineManager.shared.currentRoutine = routine
    }
}
