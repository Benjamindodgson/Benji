//
//  AlertConfirmationView.swift
//  Benji
//
//  Created by Benji Dodgson on 10/31/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class AlertConfirmationView: TextInputAccessoryView {

    func setAlertMessage(for avatars: [Avatar]) {
        var arguments = String()
        for (index, avatar) in avatars.enumerated() {
            if avatar.userObjectID != User.current()?.objectId {
                if avatars.count == 1 {
                    arguments.append(avatar.givenName + " ")
                } else if index + 1 == avatars.count, arguments.count > 1 {
                    arguments.append(" and" + avatar.givenName + " ")
                } else {
                    arguments.append(avatar.givenName + ", ")
                }
            }
        }

        if arguments.isEmpty {
            arguments.append("others ")
        }
        self.text = LocalizedString(id: "", arguments: [arguments], default: "Swipe up to alert @(handle) of this message and be notified when it is read.")
    }
}
