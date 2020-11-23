//
//  CancelButton.swift
//  Benji
//
//  Created by Benji Dodgson on 12/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CancelButton: ImageViewButton {

    override func initializeSubviews() {

        self.imageView.image = UIImage(systemName: "xmark.square")

        super.initializeSubviews()
    }
}
