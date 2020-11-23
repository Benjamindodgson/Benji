//
//  Invitee.swift
//  Benji
//
//  Created by Benji Dodgson on 3/15/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

enum InviteeKey: String {
    case phoneNumber
    case givenName
    case familyName
    case smallImage
}

final class Invitee: PFObject, PFSubclassing  {

    static let currentInviteeKey = "currentInviteeKey"

    static func parseClassName() -> String {
        return String(describing: self)
    }

    var phoneNumber: String? {
        get { return self.getObject(for: .phoneNumber) }
        set { self.setObject(for: .phoneNumber, with: newValue)}
    }

    var givenName: String {
        get { return String(optional: self.getObject(for: .givenName)) }
        set { self.setObject(for: .givenName, with: newValue) }
    }

    var familyName: String {
        get { return String(optional: self.getObject(for: .familyName)) }
        set { self.setObject(for: .familyName, with: newValue) }
    }

    var smallImage: PFFileObject? {
        get { return self.getObject(for: .smallImage) }
        set { self.setObject(for: .smallImage, with: newValue) }
    }
}

extension Invitee: Objectable {
    typealias KeyType = InviteeKey

    func getObject<Type>(for key: InviteeKey) -> Type? {
        self.object(forKey: key.rawValue) as? Type
    }

    func setObject<Type>(for key: InviteeKey, with newValue: Type) {
        self.setObject(newValue, forKey: key.rawValue)
    }

    func getRelationalObject<PFRelation>(for key: InviteeKey) -> PFRelation? {
        return self.relation(forKey: key.rawValue) as? PFRelation
    }
}
