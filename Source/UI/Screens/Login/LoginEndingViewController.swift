//
//  LoginEndingViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/19/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class LoginEndingViewController: LoginFlowableViewController {
    var didComplete: (() -> Void)?
    var didClose: (() -> Void)?

    let displayLabel = Display2Label()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.set(backgroundColor: .background3)
        self.view.addSubview(self.displayLabel)

        delay(3.0) {
            self.didComplete?()
        }

        guard let current = PFUser.current() else { return }

        let text = LocalizedString(id: "",
                                   arguments: [current.firstName],
                                   default: "@1 I made this for you.\n ~Benji")
        self.displayLabel.set(text: text, alignment: .center)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.displayLabel.setSize(withWidth: self.view.width * 0.8)
        self.displayLabel.centerOnXAndY()
    }
}
