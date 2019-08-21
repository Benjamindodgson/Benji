//
//  LoginNameViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/12/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class LoginNameViewController: LoginTextInputViewController {

    var didAddName: () -> Void = {}

    private let doneButton = LoadingButton()

    init() {
        super.init(textField: TextField(),
                   textFieldTitle: LocalizedString(id: "", default: "NAME"),
                   textFieldPlaceholder: LocalizedString(id: "", default: "FIRST LAST"))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.doneButton)
        self.doneButton.set(style: .rounded(color: .blue, text: "DONE"))
        self.doneButton.onTap { [unowned self] (tap) in
            self.updateUserName()
        }

        self.textField.autocapitalizationType = .words
        self.textField.keyboardType = .default
        self.textField.textContentType = .name
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.doneButton.size = CGSize(width: self.textField.width, height: 40)
        self.doneButton.top = self.textField.bottom + 20
        self.doneButton.centerOnX()
    }

    override func textFieldDidChange() {
        guard let text = self.textField.text,
            !text.isEmpty else {
                self.doneButton.isEnabled = false
                return
        }
        self.doneButton.isEnabled = true
    }

    private func updateUserName() {
        guard let current = PFUser.current(),
            let text = self.textField.text,
            !text.isEmpty else { return }

        current.parseName(from: text)
        self.doneButton.isLoading = true
        current.saveInBackground { (success, error) in
            guard success else { return }
            self.didAddName()
            self.doneButton.isLoading = false
        }
    }
}
