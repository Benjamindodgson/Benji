//
//  LoginTextInputViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift
import TMROLocalization

class TextInputViewController<ResultType>: ViewController, Sizeable, Completable, UITextFieldDelegate, KeyboardObservable {

    var onDidComplete: ((Result<ResultType, Error>) -> Void)?

    var textField: UITextField {
        return self.textEntry.textField
    }

    lazy var textInputAccessory = TextInputAccessoryView()
    private(set) var textEntry: TextEntryField

    init(textField: UITextField,
         title: Localized,
         placeholder: Localized?) {

        self.textEntry = TextEntryField(with: textField,
                                        title: title,
                                        placeholder: placeholder)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.textEntry)

        self.textEntry.textField.keyboardType = .numberPad

        self.textEntry.textField.addTarget(self,
                                           action: #selector(textFieldDidChange),
                                           for: UIControl.Event.editingChanged)
        self.textEntry.textField.delegate = self
        self.registerKeyboardEvents()
    }

    @objc func textFieldDidChange() {}

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let handler = self.keyboardHandler else { return }

        let width = self.view.width - (Theme.contentOffset * 2)
        let height = self.textEntry.getHeight(for: width)
        self.textEntry.size = CGSize(width: width, height: height)
        self.textEntry.centerOnX()

        let defaultOffset = self.view.height - 30
        self.textEntry.bottom = defaultOffset - handler.currentKeyboardHeight
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.shouldBecomeFirstResponder() {
            self.textEntry.textField.becomeFirstResponder()
        }
    }

    func shouldBecomeFirstResponder() -> Bool {
        return true
    }

    func getAccessoryText() -> Localized? {
        return nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {}

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = self.getAccessoryText(), !localized(text).isEmpty else { return }
        self.showAccessory()
    }

    func showAccessory() {
        self.textEntry.textField.inputAccessoryView = nil
        self.textEntry.textField.reloadInputViews()

        self.textInputAccessory.frame = CGRect(x: 0,
                                               y: 0,
                                               width: UIScreen.main.bounds.width,
                                               height: 60)
        self.textInputAccessory.keyboardAppearance = self.textEntry.textField.keyboardAppearance
        self.textInputAccessory.text = self.getAccessoryText()
        self.textEntry.textField.inputAccessoryView = self.textInputAccessory
        self.textEntry.textField.reloadInputViews()

        self.textInputAccessory.didCancel = { [unowned self] in
            self.textEntry.textField.resignFirstResponder()
        }
    }

    func handleKeyboard(frame: CGRect, with animationDuration: TimeInterval, timingCurve: UIView.AnimationCurve) {
        guard let handler = self.keyboardHandler, handler.currentKeyboardHeight > 0 else { return }

        UIView.animate(withDuration: animationDuration) {
            self.view.layoutNow()
        }
    }
}

