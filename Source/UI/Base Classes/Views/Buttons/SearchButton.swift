//
//  SearchButton.swift
//  Benji
//
//  Created by Benji Dodgson on 12/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class SearchButton: Button {

    override func initializeSubviews() {
        self.set(backgroundColor: .background2)
        self.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        self.tintColor = Color.white.color
    }
}
