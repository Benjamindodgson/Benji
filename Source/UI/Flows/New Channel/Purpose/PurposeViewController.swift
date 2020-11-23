//
//  PurposeViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class PurposeViewController: ViewController, Sizeable {

    let offset: CGFloat = Theme.contentOffset

    let textField = PurposeTitleTextField()

    lazy var contextVC = ContextCollectionViewController()

    let purposeAccessoryView = PurposeInputAccessoryView()

    var totalHeight: CGFloat = 284

    var textFieldDidBegin: CompletionOptional = nil
    var textFieldDidEnd: CompletionOptional = nil

    var textFieldTextDidChange: ((String) -> Void)?

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.textField)
        self.textField.set(backgroundColor: .background3)
        self.textField.roundCorners()

        self.textField.onTextChanged = { [unowned self] in
            guard let text = self.textField.text else { return }
            self.textFieldTextDidChange?(text)
            self.purposeAccessoryView.textColor = text.isEmpty ? .red : .white
        }

        self.textField.delegate = self

        self.addChild(viewController: self.contextVC)
        self.contextVC.view.alpha = 0 
    }

    func getHeight(for width: CGFloat) -> CGFloat {

        let newWidth = width - (self.offset * 2)

        self.textField.size = CGSize(width: newWidth, height: 72)
        self.textField.left = self.offset
        self.textField.top = 50

        let height = self.view.height - self.textField.bottom
        self.contextVC.view.size = CGSize(width: self.view.width, height: height)
        self.contextVC.view.top = self.textField.bottom
        self.contextVC.view.centerOnX()

        return self.contextVC.view.bottom
    }

    func getWidth(for height: CGFloat) -> CGFloat {
        return .zero 
    }
}

extension PurposeViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.purposeAccessoryView.showAccessoryForName(textField: textField)
        self.textFieldDidBegin?()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textFieldDidEnd?()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == " " || string == "." {
            return false
        }

        if string.count > 80 {
            return false
        }

        if let _ = string.rangeOfCharacter(from: .uppercaseLetters) {
            return false
        }

        return true
    }
}
