//
//  SystemError.swift
//  Benji
//
//  Created by Benji Dodgson on 7/5/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

enum ClientError: Swift.Error {
    public static let genericErrorString = "We're having some difficulty, please try again later"

    case apiError(detail: String?)
    case message(detail: String)
    case generic
}

extension ClientError {
    var localizedDescription: String {
        switch self {
        case .apiError(let detail):
            if let detail = detail {
                return detail
            } else {
                return ClientError.genericErrorString
            }
        case .message(let detail):
            return detail
        case .generic:
            return ClientError.genericErrorString
        }
    }
}
