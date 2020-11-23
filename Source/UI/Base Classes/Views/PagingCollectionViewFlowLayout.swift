//
//  PagingCollectionViewFlowLayout.swift
//  Benji
//
//  Created by Benji Dodgson on 2/4/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

public enum FlowLayoutSpacingMode {
    case fixed(spacing: CGFloat)
    case overlap(visibleOffset: CGFloat)
}

class PagingCollectionViewFlowLayout: UICollectionViewFlowLayout {

    fileprivate struct LayoutState {
        var size: CGSize
        var direction: UICollectionView.ScrollDirection
        func isEqual(_ otherState: LayoutState) -> Bool {
            return self.size.equalTo(otherState.size) && self.direction == otherState.direction
        }
    }

    var sideItemScale: CGFloat = 0.75
    var sideItemAlpha: CGFloat = 0.5
    var sideItemShift: CGFloat = 0.0

    let portraitRatio: CGFloat
    let landscapeRatio: CGFloat

    fileprivate var state = LayoutState(size: CGSize.zero, direction: .horizontal)

    init(portraitRatio: CGFloat,
         landscapeRatio: CGFloat) {

        self.portraitRatio = portraitRatio
        self.landscapeRatio = landscapeRatio

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func prepare() {
        super.prepare()

        guard let collectionView = self.collectionView else { return }

        let currentState = LayoutState(size: collectionView.bounds.size, direction: self.scrollDirection)
        let height = collectionView.height - self.sectionInset.top - self.sectionInset.bottom
        let itemSize = CGSize(width: collectionView.width, height: height)
        self.itemSize = itemSize

        if !self.state.isEqual(currentState) {
            self.updateLayout()
            self.state = currentState
        }
    }

    fileprivate func updateLayout() {
        guard let collectionView = self.collectionView else { return }

        let collectionSize = collectionView.bounds.size
        let isHorizontal = (self.scrollDirection == .horizontal)

        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)

        let side = isHorizontal ? self.itemSize.width : self.itemSize.height
        let scaledItemOffset =  (side - side*self.sideItemScale) / 2

        var ratio: CGFloat = 0

        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .unknown:
            ratio = self.portraitRatio
        case .landscapeLeft, .landscapeRight, .faceDown:
            ratio = self.landscapeRatio
        @unknown default:
            ratio = self.portraitRatio
        }

        let spacing: CGFloat = collectionView.width * ratio
        let spacingMode = FlowLayoutSpacingMode.overlap(visibleOffset: spacing)

        switch spacingMode  {
        case .overlap(let visibleOffset):
            let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
            let inset = isHorizontal ? xInset : yInset
            self.minimumLineSpacing = inset - fullSizeSideItemOverlap
        default:
            break
        }
    }

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        return attributes.map({ attribute in
            let copy = attribute.copy() as! UICollectionViewLayoutAttributes
            return self.transformLayoutAttributes(copy)
        })
    }

    fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        let isHorizontal = (self.scrollDirection == .horizontal)

        let collectionCenter = isHorizontal ? collectionView.halfWidth : collectionView.halfHeight
        let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset

        let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance

        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        let shift = (1 - ratio) * self.sideItemShift
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 10)

        if isHorizontal {
            attributes.center.y = attributes.center.y + shift
        } else {
            attributes.center.x = attributes.center.x + shift
        }

        return attributes
    }

    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView , !collectionView.isPagingEnabled,
            let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
            else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        let isHorizontal = (self.scrollDirection == .horizontal)

        let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
        let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide

        var targetContentOffset: CGPoint
        if isHorizontal {
            let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
        }
        else {
            let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
        }

        return targetContentOffset
    }
}
