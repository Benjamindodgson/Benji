//
//  TCHMember+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 9/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse
import TMROFutures

extension TCHMember: Avatar {

    var givenName: String {
        return String()
    }

    var familyName: String {
        return String()
    }

    var handle: String? {
        return nil
    }

    var image: UIImage? {
        return nil
    }

    var userObjectID: String? {
        return self.identity
    }
}

extension TCHMember {
    func getMemberAsUser() -> Future<User> {

        let promise = Promise<User>()
        if let authorID = self.identity {
            User.localThenNetworkQuery(for: authorID)
                .observeValue(with: { (user) in
                    promise.resolve(with: user)
                })
        } else {
            promise.reject(with: ClientError.message(detail: "Failed to find author ID."))
        }

        return promise
    }
}

