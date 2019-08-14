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
}
