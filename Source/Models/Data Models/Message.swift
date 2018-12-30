//
//  Message.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class Message: DisplayableCellItem, ResourceObject {

    var photoUrl: URL? {
        return nil
    }

    var photo: UIImage? {
        return nil
    }

    var id: String
    var text: Localized
    var backgroundColor: Color

    init(id: String,
         text: Localized,
         backgroundColor: Color) {

        self.id = id
        self.text = text
        self.backgroundColor = backgroundColor
    }

    var isSender: Bool {
        return self.backgroundColor == .blue
    }
}
