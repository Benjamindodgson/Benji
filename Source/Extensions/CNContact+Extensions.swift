//
//  CNContact+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 6/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Contacts
import Parse 

infix operator ~~: ComparisonPrecedence
infix operator !~: ComparisonPrecedence

extension CNContact {

    var fullName: String {
        return self.givenName + " " + self.familyName
    }

    static func ~~(lhs: CNContact, rhs: CNContact) -> Bool {
        return
            lhs.namePrefix == rhs.namePrefix &&
                lhs.givenName  == rhs.givenName &&
                lhs.familyName == rhs.familyName &&
                lhs.nameSuffix == rhs.nameSuffix &&
                lhs.birthday   == rhs.birthday
    }

    static func !~(lhs: CNContact, rhs: CNContact) -> Bool {
        return !(lhs ~~ rhs)
    }

    func familyNameStartsWith(aLetter: Character) -> Bool {
        return self.familyName.count > 0 && self.familyName.first == aLetter
    }

    func givenNameStartsWith(aLetter: Character) -> Bool {
        return self.givenName.count > 0 && self.givenName.first == aLetter
    }

    func doesMatch(searchString: String) -> Bool {
        let cleanedSearchText = searchString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let firstName = self.givenName.lowercased()
        let lastName = self.familyName.lowercased()
        let fullName = firstName + " " + lastName

        if firstName.hasPrefix(cleanedSearchText) {
            return true
        } else if lastName.hasPrefix(cleanedSearchText) {
            return true
        } else if fullName.hasPrefix(searchString.lowercased()) {
            return true
        } else {
            return false
        }
    }
}

extension CNContact: DisplayableCellItem {
    var backgroundColor: Color {
        return .background3
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSObjectProtocol
    }
}

extension CNContact: Avatar {

    var initials: String {
        guard let first = self.givenName.first,
            let last = self.familyName.first else { return "?" }

        return String(first) + String(last)
    }

    var user: PFUser? {
        return nil
    }

    var photo: UIImage? {
        if let imageData = self.thumbnailImageData {
            return UIImage(data: imageData)
        }
        return nil
    }

    var firstName: String {
        return self.givenName
    }

    var lastName: String {
        return self.familyName
    }

    var handle: String {
        return "@\(self.firstName)"
    }

    var userObjectID: String? {
        return nil
    }
}
