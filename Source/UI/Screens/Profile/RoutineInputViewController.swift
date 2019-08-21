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

    var selectedDate: Date {
        return self.content.timePicker.date
    }

    override func loadView() {
        self.view = self.content

        self.content.setRoutineButton.addTarget(self,
                                                action: #selector(setRoutineTapped(_:)),
                                                for: .touchUpInside)
    }

    @objc func setRoutineTapped(_ sender: UIButton) {
        let routine = Routine(messageCheckTime: self.selectedDate)
        RoutineManager.shared.scheduleNotification(for: routine)
    }
}
