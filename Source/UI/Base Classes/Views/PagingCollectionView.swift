//
//  PagingCollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/4/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class PagingCollectionView: CollectionView {

    // Proportion of view width that is deemed a page margin. Taps in the margin area can
    // be used to automatically scroll to the next/previous page. The value should be between 0 and 0.5
    var pageTapMargin: CGFloat = 0.15

    init(pagingLayout: PagingCollectionViewFlowLayout) {

        pagingLayout.scrollDirection = .horizontal

        super.init(layout: pagingLayout)

        self.isPagingEnabled = false
        self.decelerationRate = .fast
        self.clipsToBounds = false
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func centerMostCell() -> UICollectionViewCell? {
        let point = CGPoint(x: self.centerX + self.contentOffset.x,
                            y: self.centerY + self.contentOffset.y)
        guard let indexPath = self.indexPathForItem(at: point) else { return nil }

        return self.cellForItem(at: indexPath)
    }


    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        guard self.isUserInteractionEnabled,
            !self.isHidden,
            self.alpha > 0.01,
            self.point(inside: point, with: event) else {
                return nil
        }

        guard let parent = self.superview else {
            return super.hitTest(point, with: event)
        }

        let pointInParent = self.convert(point, to: parent).x
        // Only let subviews handle touches if they're in the middle of this view
        if self.pageTapMargin * frame.width < pointInParent
            && pointInParent < (1 - self.pageTapMargin) * frame.width {
            return super.hitTest(point, with: event)
        } else {
            return self
        }
    }
}
