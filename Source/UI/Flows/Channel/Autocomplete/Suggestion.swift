//
//  Suggestion.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum SuggestionType: ManageableCellItem {

    case text(String)

    var id: String {
        switch self {
        case .text(let text):
            return text
        }
    }
}
