//
//  ChatToken+Cloud.swift
//  Benji
//
//  Created by Benji Dodgson on 5/14/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

struct GetChatToken: CloudFunction {

    func makeRequest() -> Future<String> {
        let promise = Promise<String>()

        PFCloud.callFunction(inBackground: "getChatToken",
                             withParameters: [:]) { (object, error) in
                                                if let error = error {
                                                    SessionManager.shared.handleParse(error: error)
                                                    promise.reject(with: error)
                                                } else if let token = object as? String {
                                                    promise.resolve(with: token)
                                                }
        }

        return promise.withResultToast()
    }
}
