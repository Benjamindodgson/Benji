//
//  Array+Extensions.swift
//  TMROLocalization
//
//  Created by Benji Dodgson on 11/15/19.
//  Copyright © 2019 Tomorrow Ideas. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
