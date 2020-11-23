//
//  Dismissable.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol Dismissable {
    var dismissHandlers: [() -> Void] { get set }
}

extension Dismissable where Self: UIViewController {
    var isBeingClosed: Bool {
        return self.isBeingDismissed ||
            self.isMovingFromParent ||
            self.navigationController?.isBeingDismissed ?? false
    }
}

extension Dismissable where Self: UIActivityViewController {
    var isBeingClosed: Bool {
        return self.isBeingDismissed ||
            self.isMovingFromParent ||
            self.navigationController?.isBeingDismissed ?? false
    }
}
