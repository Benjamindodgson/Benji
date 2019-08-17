//
//  ContactsScrolledModalController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContactsScrolledModalController: ScrolledTitleModalViewController {

    let contactsVC: ContactsViewController

    init() {
        let vc = ContactsViewController()
        self.contactsVC = vc
        super.init(presentable: vc)
        self.titleText = LocalizedString(id: "", default: "Contacts")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
