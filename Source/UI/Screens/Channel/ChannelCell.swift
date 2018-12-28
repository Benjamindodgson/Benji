//
//  ChannelCell.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCell: UICollectionViewCell, DisplayableCell {
    var didSelect: ((IndexPath) -> Void)?
    var item: DisplayableCellItem?

    func cellIsReadyForLayout() {
        guard let item = self.item else { return }

        print(item.text)
    }
}
