//
//  LoginPhoneViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import PhoneNumberKit
import Parse
import TMROLocalization
import TMROFutures

class PhoneViewController: TextInputViewController<PhoneNumber> {

    private let reservationId: String?
    private let reservationCreatorId: String?

    init(with reservationId: String?,
         reservationCreatorId: String?) {

        self.reservationId = reservationId
        self.reservationCreatorId = reservationCreatorId
        let phoneField = PhoneTextField(frame: .zero)
        phoneField.withFlag = true
        phoneField.withDefaultPickerUI = true
        phoneField.withExamplePlaceholder = true

        super.init(textField: phoneField,
                   title: LocalizedString(id: "", default: "MOBILE NUMBER"),
                   placeholder: phoneField.placeholder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.textField.autocorrectionType = .yes
        self.textField.textContentType = .telephoneNumber

        self.textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    override func textFieldDidChange() {
        if self.isPhoneNumberValid() {
            // End editing because we have a valid phone number and we're ready to request a code with it
            self.textField.resignFirstResponder()
        }
    }

    @objc func editingDidEnd() {
        guard let text = self.textField.text,
            text.isValidPhoneNumber(),
            let phoneTextField = self.textField as? PhoneTextField,
            let phone = try? PhoneKit.shared.parse(text, withRegion: phoneTextField.currentRegion) else {
                return
        }

        self.sendCode(to: phone, region: phoneTextField.currentRegion)
    }

    private func isPhoneNumberValid() -> Bool {
        if let phoneString = self.textField.text, phoneString.isValidPhoneNumber() {
            return true
        }
        return false
    }

    private func sendCode(to phone: PhoneNumber, region: String) {
        guard let installationId = UserNotificationManager.shared.installationId else { return }

        let tf = self.textField as? PhoneTextField
        tf?.animationView.play()
        SendCode(phoneNumber: phone,
                 region: region,
                 installationId: installationId,
                 reservationId: self.reservationId)
            .makeRequest()
            .withResultToast()
            .observe(with: { (result) in
                tf?.animationView.stop()
                switch result {
                case .success:
                    self.complete(with: .success(phone))
                case .failure(let error):
                    self.complete(with: .failure(error))
                }
            })
    }
}

