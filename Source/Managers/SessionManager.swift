//
//  SessionManager.swift
//  Benji
//
//  Created by Benji Dodgson on 4/27/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class SessionManager {
    static let shared = SessionManager()
    var didReceiveInvalidSessionError: ((Error) -> ())?

    func handleParse(error: Error) {
        if error.code == 209 {
            self.didReceiveInvalidSessionError?(error)
        }
    }
}
