//
//  User+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 11/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

extension User: Avatar {

    var userObjectID: String? {
        self.objectId
    }

    var image: UIImage? {
        return nil
    }

    var isOnboarded: Bool {

        if self.fullName.isEmpty {
            return false
        } else if self.smallImage == nil {
            return false
        }

        return true 
    }

    var isCurrentUser: Bool {
        return self.objectId == User.current()?.objectId
    }
}

extension User {

    func getRoutine() -> Future<Routine> {
        let promise = Promise<Routine>()

        if let routine = self.routine {
            if routine.isDataAvailable {
                promise.resolve(with: routine)
            } else {
                self.routine?.retrieveDataIfNeeded()
                    .observe(with: { (result) in
                        switch result {
                        case .success(let routine):
                            runMain {
                                promise.resolve(with: routine)
                            }
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    })
                self.routine?.fetchInBackground(block: { (object, error) in

                })
            }
        } else {
            promise.reject(with: ClientError.message(detail: "Failed to retrieve your routine."))
        }

        return promise.withResultToast()
    }
}

extension User: ManageableCellItem {
    var id: String {
        return self.objectId!
    }
}

extension User {
    
    func formatName(from text: String) {
        let components = text.components(separatedBy: " ").filter { (component) -> Bool in
            return !component.isEmpty
        }
        if let first = components.first {
            self.givenName = first
        }
        if let last = components.last {
            self.familyName = last
        }
    }
}
