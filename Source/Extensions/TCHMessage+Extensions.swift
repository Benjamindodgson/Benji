//
//  TCHMessages+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse

extension TCHMessage: Diffable, DisplayableCellItem, Avatar {

    var backgroundColor: Color {
        get {
            return self.isFromCurrentUser ? .purple : .lightPurple
        }
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return String(optional: self.sid) as NSObjectProtocol
    }

    var isFromCurrentUser: Bool {
        guard let author = self.author,
            let identity = PFUser.current()?.objectId else { return false }
        return author == identity
    }

    //TODO: Fill these in
    var handle: String {
        return "@handle"
    }

    var firstName: String {
        return String()
    }

    var lastName: String {
        return String()
    }
    
    var initials: String {
        return String()
    }

    var user: PFUser? {
        return nil
    }

    var photo: UIImage? {
        return nil
    }

    var userObjectID: String? {
        return self.author
    }
}

extension Future where Value == TCHMessage {

    func getAuthorAsUser() -> Future<PFUser> {
        return self.then(with: { (message) in
            let promise = Promise<PFUser>()
            if let authorID = message.author,
                let query = PFUser.query() {
                query.whereKey("objectId", equalTo: authorID)
                query.getFirstObjectInBackground(block: { (object, error) in
                    if let error = error {
                        promise.reject(with: error)
                    } else if let user = object as? PFUser {
                        promise.resolve(with: user)
                    } else {
                        promise.reject(with: ClientError.generic)
                    }
                })
            } else {
                promise.reject(with: ClientError.generic)
            }

            return promise
        })
    }
}
