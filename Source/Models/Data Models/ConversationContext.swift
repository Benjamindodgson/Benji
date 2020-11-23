//
//  ConversationContext.swift
//  Benji
//
//  Created by Benji Dodgson on 4/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

enum ConversationContext: String, CaseIterable, ManageableCellItem {

    case casual
    case event
    case important
    case meetup
    case delayed
    case custom

    var id: String {
        return self.rawValue
    }

    var title: Localized {
        switch self {
        case .casual:
            return "casual"
        case .event:
            return "event"
        case .important:
            return "important"
        case .meetup:
            return "meetup"
        case .delayed:
            return "delayed"
        case .custom:
            return "custom"
        }
    }

    var text: Localized {
        return ""
    }

    var color: Color {
        switch self {
        case .casual:
            return .white
        case .event:
            return .blue
        case .important:
            return .red
        case .meetup:
            return .green
        case .delayed:
            return .orange
        case .custom:
            return .teal
        }
    }
}

