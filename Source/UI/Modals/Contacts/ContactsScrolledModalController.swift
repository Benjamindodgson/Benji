//
//  ContactsScrolledModalController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContactsScrolledModalController: ScrolledModalViewController<ContactsViewController> {

    init() {
        super.init(presentable: ContactsViewController())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
