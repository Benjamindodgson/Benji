//
//  ChannelCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/28/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCollectionView: CollectionView {

    weak var channelDataSource: ChannelDataSource?

    lazy var emptyView = EmptyChannelView()

    var channelCollectionViewFlowLayout: ChannelCollectionViewFlowLayout {
        guard let layout = collectionViewLayout as? ChannelCollectionViewFlowLayout else {
            fatalError("ChannelCollectionViewFlowLayout NOT FOUND")
        }
        return layout
    }

    init(with flowLayout: ChannelCollectionViewFlowLayout) {
        super.init(flowLayout: flowLayout)
        self.registerReusableViews()
        self.backgroundView = self.emptyView
        self.backgroundView?.alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateEmptyView(shouldShow: Bool) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.backgroundView?.alpha = shouldShow ? 1 : 0
        }
    }

    private func registerReusableViews() {
        self.register(MessageCell.self)
        self.register(ChannelSectionHeader.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.emptyView.frame = self.backgroundView?.bounds ?? .zero
    }
}
