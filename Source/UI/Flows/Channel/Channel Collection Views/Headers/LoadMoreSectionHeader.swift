//
//  LoadMoreSectionHeader.swift
//  Benji
//
//  Created by Benji Dodgson on 9/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class LoadMoreSectionHeader: UICollectionReusableView {

    private(set) var button = LoadingButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    private func initializeViews() {

        self.addSubview(self.button)

        self.set(backgroundColor: .clear)
        self.button.set(style: .rounded(color: .orange, text: "LOAD MORE"))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.button.size = CGSize(width: 140, height: 34)
        self.button.centerOnXAndY()
    }
}
