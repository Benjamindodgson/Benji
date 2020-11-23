//
//  Onboarding+CloudCalls.swift
//  Benji
//
//  Created by Benji Dodgson on 2/11/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures
import PhoneNumberKit

struct SendCode: CloudFunction {

    let phoneNumber: PhoneNumber
    let region: String
    let installationId: String
    let reservationId: String?

    func makeRequest() -> Future<Void> {
        let promise = Promise<Void>()
        let params = ["phoneNumber": PhoneKit.shared.format(self.phoneNumber, toType: .e164),
                      "installationId": self.installationId,
                      "reservationId": String(optional: self.reservationId),
                      "region": self.region]
        PFCloud.callFunction(inBackground: "sendCode",
                             withParameters: params) { (object, error) in
                                if let error = error {
                                    SessionManager.shared.handleParse(error: error)
                                    promise.reject(with: error)
                                } else {
                                    promise.resolve(with: ())
                                }
        }

        return promise.withResultToast()
    }
}

enum VerifyCodeResult {
    case success(String)
    case addedToWaitlist
}

struct VerifyCode: CloudFunction {

    let code: String
    let phoneNumber: PhoneNumber
    let installationId: String
    let reservationId: String

    func makeRequest() -> Future<VerifyCodeResult> {
        let promise = Promise<VerifyCodeResult>()

        let params: [String: Any] = ["authCode": self.code,
                                     "installationId": self.installationId,
                                     "reservationId": self.reservationId,
                                     "phoneNumber": PhoneKit.shared.format(self.phoneNumber, toType: .e164)]

        PFCloud.callFunction(inBackground: "validateCode",
                             withParameters: params) { (object, error) in
                                if let error = error {
                                    if (error as NSError).code == 100 {
                                        promise.resolve(with: .addedToWaitlist)
                                    } else {
                                        SessionManager.shared.handleParse(error: error)
                                        promise.reject(with: error)
                                    }
                                } else if let token = object as? String {
                                    promise.resolve(with: .success(token))
                                }
        }

        return promise.withResultToast()
    }
}
