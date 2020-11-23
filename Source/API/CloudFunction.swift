//
//  CloudCalls.swift
//  Benji
//
//  Created by Benji Dodgson on 9/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

protocol CloudFunction {
    associatedtype ReturnType

    func makeRequest() -> Future<ReturnType>
}
