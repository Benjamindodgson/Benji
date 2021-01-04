//
//  ViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController, Dismissable {

    var dismissHandlers: [() -> Void] = []
    var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    func initializeViews() {
        self.view.translatesAutoresizingMaskIntoConstraints = true
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

