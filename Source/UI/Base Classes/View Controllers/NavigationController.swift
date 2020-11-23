//
//  NavigationController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class NavigationController: UINavigationController, Dismissable {
    var dismissHandlers: [() -> Void] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.set(backgroundColor: .background1)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isBeingClosed {
            self.viewWasDismissed()
            self.dismissHandlers.forEach { (dismissHandler) in
                dismissHandler()
            }
        }
    }

    func viewWasDismissed() { }
}
