//
//  LocalizedString.swift
//  TMROLocalization
//
//  Created by Benji Dodgson on 11/4/19.
//  Copyright © 2019 Tomorrow Ideas. All rights reserved.
//

import Foundation

public struct LocalizedString: Localized {

    public var identifier: String
    public var arguments: [Localized]
    public var defaultString: String?
    public var isEmpty: Bool {
        get {
            return LocalizedStringLibrary.shared.getLocalizedString(for: self).isEmpty
        }
    }

    public init(id: String,
                arguments: [Localized] = [],
                default: String?) {

        self.identifier = id
        self.arguments = arguments
        self.defaultString = `default`
    }

    public static var empty: LocalizedString {
        return LocalizedString(id: "", default: "")
    }
}
