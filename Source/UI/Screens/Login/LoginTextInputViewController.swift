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
    let toolbar = UIToolbar()
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

        self.view.set(backgroundColor: .background3)
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

        self.view.round(corners: [.topLeft, .topRight], size: CGSize(width: 10, height: 10))

        self.textFieldLabel.size = CGSize(width: 200, height: 20)
        self.textFieldLabel.left = 14
        self.textFieldLabel.top = 80

        self.textField.height = 50
        self.textField.width = self.view.width - 28
        self.textField.top = self.textFieldLabel.bottom + 5
        self.textField.left = self.textFieldLabel.left
        self.textField.setBottomBorder(color: .blue)
    }
}

extension LoginTextInputViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {}
}

