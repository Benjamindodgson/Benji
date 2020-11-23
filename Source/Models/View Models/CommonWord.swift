//
//  CommonWord.swift
//  Benji
//
//  Created by Benji Dodgson on 7/1/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

enum CommonWord {

    case me(StringCasing)
    case _import(StringCasing)
    case maybelater(StringCasing)
    case dismiss(StringCasing)
    case next(StringCasing)
    case remove(StringCasing)
    case delete(StringCasing)
    case nevermind(StringCasing)
    case signup(StringCasing)
    case login(StringCasing)
    case ok(StringCasing)

    var localizedString: Localized {
        switch self {
        case .me(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.me", default: "me")))
        case ._import(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.import", default: "import")))
        case .maybelater(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.maybelater", default: "maybe later")))
        case .dismiss(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.dismiss", default: "dismiss")))
        case .next(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.next", default: "next")))
        case .delete(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.delete", default: "delete")))
        case .remove(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.remove", default: "remove")))
        case .nevermind(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.nevermind", default: "never mind")))
        case .signup(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.signup", default: "Sign-Up")))
        case .login(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.login", default: "login")))
        case .ok(let stringCasing):
            return stringCasing.format(string: localized(LocalizedString(id: "common.ok", default: "ok")))
        }
    }
}

