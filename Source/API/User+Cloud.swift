//
//  User+Cloud.swift
//  Benji
//
//  Created by Benji Dodgson on 5/30/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

struct UpdateUser: CloudFunction {

    var attributes: [String: Any]

    func makeRequest() -> Future<Void> {
        let promise = Promise<Void>()

        PFCloud.callFunction(inBackground: "updateUser",
                             withParameters: self.attributes) { (object, error) in
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
