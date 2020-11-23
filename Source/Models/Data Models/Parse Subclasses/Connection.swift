//
//  Conneciton.swift
//  Benji
//
//  Created by Benji Dodgson on 11/2/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

enum ConnectionKey: String {
    case status
    case to
    case from
    case channelSid
}

final class Connection: PFObject, PFSubclassing {

    static func parseClassName() -> String {
        return String(describing: self)
    }

    enum Status: String {
        case invited
        case pending
        case accepted
        case declined
    }

    var status: Status? {
        guard let string: String = self.getObject(for: .status) else { return nil }
        return Status(rawValue: string)
    }

    var to: User? {
        return self.getObject(for: .to)
    }

    var from: User? {
        return self.getObject(for: .from)
    }

    var channelId: String? {
        return self.getObject(for: .channelSid)
    }

    var nonMeUser: User? {
        if self.to?.objectId == User.current()?.objectId {
            return self.from
        } else {
            return self.to
        }
    }
}

extension Connection: Objectable {
    typealias KeyType = ConnectionKey

    func getObject<Type>(for key: ConnectionKey) -> Type? {
        return self.object(forKey: key.rawValue) as? Type
    }

    func setObject<Type>(for key: ConnectionKey, with newValue: Type) {
        self.setObject(newValue, forKey: key.rawValue)
    }

    func getRelationalObject<PFRelation>(for key: ConnectionKey) -> PFRelation? {
        return self.relation(forKey: key.rawValue) as? PFRelation
    }
}

extension Connection: ManageableCellItem {
    var id: String {
        return self.objectId!
    }
}
