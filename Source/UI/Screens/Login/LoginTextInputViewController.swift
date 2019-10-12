//
//  LoginTextInputViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift

class LoginTextInputViewController: ViewController {

    let textField: UITextField
    let textFieldLabel = Label()
    let textFieldTitle: Localized
    let textFieldPlaceholder: Localized?

    init(textField: UITextField,
         textFieldTitle: Localized,
         textFieldPlaceholder: Localized?) {

        self.textField = textField
        self.textFieldTitle = textFieldTitle
        self.textFieldPlaceholder = textFieldPlaceholder

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .background1)
        let attributed = AttributedString(self.textFieldTitle,
                                          fontType: .xxSmallSemiBold,
                                          color: .white)
        self.textFieldLabel.set(attributed: attributed,
                                lineCount: 1,
                                stringCasing: .uppercase)
        self.view.addSubview(self.textFieldLabel)

        self.initializeTextField()
    }

    func initializeTextField() {
        self.textField.keyboardType = .numberPad
        self.textField.returnKeyType = .done
        self.textField.adjustsFontSizeToFitWidth = true
        if let placeholder = self.textFieldPlaceholder {
            let attributed = AttributedString(placeholder, fontType: .medium, color: .white)
            self.textField.setPlaceholder(attributed: attributed)
            self.textField.setDefaultAttributes(style: StringStyle(font: .medium, color: .white))
        }

        self.textField.addTarget(self,
                                 action: #selector(textFieldDidChange),
                                 for: UIControl.Event.editingChanged)
        self.textField.delegate = self

        self.view.addSubview(self.textField)
    }

    @objc func textFieldDidChange() {}

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.textField.height = 50
        self.textField.width = self.view.width * 0.8
        self.textField.centerOnX()
        self.textField.centerY = self.view.halfHeight * 0.8
        self.textField.setBottomBorder(color: .background2)

        self.textFieldLabel.setSize(withWidth: self.textField.width)
        self.textFieldLabel.left = self.textField.left
        self.textFieldLabel.bottom = self.textField.top - 5
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.textField.becomeFirstResponder()
    }
}

extension LoginTextInputViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {}
}

