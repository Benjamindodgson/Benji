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

extension CNContact: ManageableCellItem {

    var id: String {
        return self.identifier
    }
}

extension CNContact: Avatar {

    var image: UIImage? {
        if let imageData = self.thumbnailImageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    var userObjectID: String? {
        return nil
    }
}

extension CNContact {

    var primaryPhoneNumber: String? {
        guard let prioritizedNumber = self.findBestPhoneNumber(self.phoneNumbers).phone else { return nil }
        return prioritizedNumber.stringValue.formatPhoneNumber()
    }

    func findBestPhoneNumber(_ numbers: [CNLabeledValue<CNPhoneNumber>]) -> (phone: CNPhoneNumber?, label: String?) {

        var bestPair: (CNPhoneNumber?, String?) = (nil, nil)
        let prioritizedLabels = ["iPhone",
                                 "_$!<Mobile>!$_",
                                 "_$!<Main>!$_",
                                 "_$!<Home>!$_",
                                 "_$!<Work>!$_"]

        // Look for a number with a priority label first
        for label in prioritizedLabels {
            for entry: CNLabeledValue in numbers {
                if entry.label == label {
                    let readableLabel = self.readable(label)
                    bestPair = (entry.value, readableLabel)
                    break
                }
            }
        }

        // Then look to see if there are any numbers with custom labels if we
        // didn't find a priority label
        if bestPair.0 == nil || bestPair.1 == nil {
            let lowPriority = numbers.filter { entry in
                if let label = entry.label {
                    return !prioritizedLabels.contains(label)
                } else {
                    return false
                }
            }

            if let entry = lowPriority.first, let label = entry.label {
                let readableLabel = self.readable(label)
                bestPair = (entry.value, readableLabel)
            }
        }

        return bestPair
    }

    func readable(_ label: String) -> String {
        let cleanLabel: String

        switch label {
        case _ where label == "iPhone":         cleanLabel = "iPhone"
        case _ where label == "_$!<Mobile>!$_": cleanLabel = "Mobile"
        case _ where label == "_$!<Main>!$_":   cleanLabel = "Main"
        case _ where label == "_$!<Home>!$_":   cleanLabel = "Home"
        case _ where label == "_$!<Work>!$_":   cleanLabel = "Work"
        default:                                cleanLabel = label
        }

        return cleanLabel
    }
}
