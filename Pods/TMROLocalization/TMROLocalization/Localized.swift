//
//  Localized.swift
//  TMROLocalization
//
//  Created by Benji Dodgson on 11/4/19.
//  Copyright © 2019 Tomorrow Ideas. All rights reserved.
//

import Foundation

public protocol Localized {
    var identifier: String { get }
    var arguments: [Localized] { get }
    var defaultString: String? { get }
    var isEmpty: Bool { get }
}

public func ==(lhs: Localized, rhs: Localized) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    return lhs.identifier == rhs.identifier
}

