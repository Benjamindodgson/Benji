//
//  FeedCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 11/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Koloda

class FeedCollectionView: KolodaView {

    let defaultTopOffset: CGFloat = 20
    let defaultHorizontalOffset: CGFloat = 20
    let defaultHeightRatio: CGFloat = 0.8
    let backgroundCardHorizontalMarginMultiplier: CGFloat = 0.25
    let backgroundCardScalePercent: CGFloat = 0.9

    override func frameForCard(at index: Int) -> CGRect {

        switch index {
        case 0:
            let topOffset: CGFloat = self.defaultTopOffset
            let xOffset: CGFloat = self.defaultHorizontalOffset
            let width = self.bounds.width - (2 * self.defaultHorizontalOffset)
            let height = self.bounds.height * self.defaultHeightRatio
            let frame = CGRect(x: xOffset, y: topOffset, width: width, height: height)
            return frame
        case 1:
            let topOffset: CGFloat = 30
            let width = self.bounds.width - (4 * self.defaultHorizontalOffset)
            let height = self.bounds.height * self.defaultHeightRatio
            let xOffset = self.defaultHorizontalOffset * 2
            return CGRect(x: xOffset, y: topOffset, width: width, height: height)
        default:
            let topOffset: CGFloat = 40
            let width = self.bounds.width - (6 * self.defaultHorizontalOffset)
            let height = self.bounds.height * self.defaultHeightRatio
            let xOffset = self.defaultHorizontalOffset * 3
            return CGRect(x: xOffset, y: topOffset, width: width, height: height)
        }
    }
}
