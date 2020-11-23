//
//  Channel+Cloud.swift
//  Benji
//
//  Created by Benji Dodgson on 5/4/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

struct CreateChannel: CloudFunction {

    var uniqueName: String
    var friendlyName: String
    var attributes: [String: Any]
    var members: [String]

    func makeRequest() -> Future<Void> {
        let promise = Promise<Void>()

        let params: [String: Any] = ["uniqueName": self.uniqueName,
                                     "friendlyName": self.friendlyName,
                                     "type": "private",
                                     "attributes": self.attributes,
                                     "members": self.members]
        PFCloud.callFunction(inBackground: "createChannel",
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
