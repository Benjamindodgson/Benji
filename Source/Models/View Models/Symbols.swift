//
//  Symbols.swift
//  Benji
//
//  Created by Benji Dodgson on 9/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum Symbols {

    case search
    case add

    var image: UIImage {
        switch self {
        case .search:
            return UIImage(systemName: "", withConfiguration: nil) ?? UIImage()
        case .add:
            return UIImage(systemName: "", withConfiguration: nil) ?? UIImage()
        }
    }
}
