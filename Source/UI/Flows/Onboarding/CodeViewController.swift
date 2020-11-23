//
//  LoginCodeViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import PhoneNumberKit
import ReactiveSwift
import Parse
import TMROLocalization
import TMROFutures
import Branch

class CodeViewController: TextInputViewController<Void> {

    var phoneNumber: PhoneNumber?
    let reservationId: String?
    init(with reservationId: String?) {
        self.reservationId = reservationId
        super.init(textField: TextField(),
                   title: LocalizedString(id: "", default: "CODE"),
                   placeholder: LocalizedString(id: "", default: "0000"))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textFieldDidChange() {
        guard let code = self.textField.text, code.extraWhitespaceRemoved().count == 4 else { return }
        self.verify(code: code)
    }

    // True if we're in the process of verifying the code
    var verifying: Bool = false
    private func verify(code: String) {
        guard !self.verifying, let phoneNumber = self.phoneNumber, let installationId = PFInstallation.current()?.installationId else { return }

        self.verifying = true

        let tf = self.textField as? TextField
        tf?.animationView.play()
        
        VerifyCode(code: code,
                   phoneNumber: phoneNumber,
                   installationId: installationId,
                   reservationId: String(optional: self.reservationId))
            .makeRequest()
            .observeValue { (result) in
                switch result {
                case .success(let token):
                    self.becomeUser(with: token)
                case .addedToWaitlist:
                    break
                }

                tf?.animationView.stop()
                self.textField.resignFirstResponder()
        }
    }

    private func becomeUser(with token: String) {
        User.become(inBackground: token) { (user, error) in
            if let identity = user?.objectId {
                Branch.getInstance().setIdentity(identity)
                UserNotificationManager.shared.silentRegister(withApplication: UIApplication.shared)
                self.complete(with: .success(()))
            } else if let error = error {
                self.complete(with: .failure(error))
            } else {
                self.complete(with: .failure(ClientError.message(detail: "Verification failed.")))
            }
        }
    }
}
