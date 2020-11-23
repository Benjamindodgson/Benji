//
//  String+Extension.swift
//  TMROLocalization
//
//  Created by Benji Dodgson on 11/4/19.
//  Copyright © 2019 Tomorrow Ideas. All rights reserved.
//

import Foundation

public extension String {
    
    init(optional value: String?) {
        if let strongValue = value {
            self.init(stringLiteral: strongValue)
        } else {
            self.init()
        }
    }
}

extension String: Localized {

    public var identifier: String {
        return String()
    }

    public var arguments: [Localized] {
        return []
    }

    public var defaultString: String? {
        return self
    }
} 
