//
//  Toast.swift
//  Benji
//
//  Created by Benji Dodgson on 7/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

struct Toast: Equatable {
    var id: String
    var analyticsID: String
    var priority: Int = 0
    var title: Localized
    var description: Localized
    var avatar: Avatar
    var didTap: () -> Void

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        return lhs.id == rhs.id
    }
}
