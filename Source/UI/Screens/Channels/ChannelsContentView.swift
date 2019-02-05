//
//  ChannelsContentView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelsContentView: View {

    lazy var collectionView: ChannelsCollectionView = {
        return ChannelsCollectionView()
    }()

    @IBOutlet weak var collectionViewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.set(backgroundColor: .clear)

        self.collectionViewContainer.addSubview(self.collectionView)
        self.collectionView.autoPinEdgesToSuperviewEdges()
    }
}