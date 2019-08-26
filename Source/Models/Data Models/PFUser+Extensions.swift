//
//  User.swift
//  Benji
//
//  Created by Benji Dodgson on 6/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

extension PFUser: Avatar {

    static var current: PFUser = PFUser.current()!

    var user: PFUser? {
        return self
    }

    var photo: UIImage? {
        return nil
    }

    var initials: String {
        let firstInitial = String(optional: self.firstName.first?.uppercased())
        let lastInitial = String(optional: self.lastName.first?.uppercased())
        return firstInitial + lastInitial
    }

    var firstName: String {
        get {
            return String(optional: self.object(forKey: "firstName") as? String)
        }
        set {

            self.setObject(newValue, forKey: "firstName")
        }
    }

    var lastName: String {
        get {
            return String(optional: self.object(forKey: "lastName") as? String)
        }
        set {

            self.setObject(newValue, forKey: "lastName")
        }
    }

    var handle: String {
        get {
            return String(optional: self.object(forKey: "handle") as? String)
        }
        set {

            self.setObject(newValue, forKey: "handle")
        }
    }

    var userObjectID: String? {
        return self.objectId
    }

    func parseName(from text: String) {
        let components = text.components(separatedBy: " ").filter { (component) -> Bool in
            return !component.isEmpty
        }
        if let first = components.first {
            self.firstName = first 
        }
        if let last = components.last {
            self.lastName = last
        }
    }

    func createHandle() {
        guard let last = self.lastName.first, let id = self.objectId else { return }
        self.handle = self.firstName + String(last) + "_" + id
    }
}

extension PFUser {

    var phoneNumber: String? {
        get {
            return self.object(forKey: "phoneNumber") as? String
        }
        set {
            self.setObject(newValue ?? NSNull(), forKey: "phoneNumber")
        }
    }
}
