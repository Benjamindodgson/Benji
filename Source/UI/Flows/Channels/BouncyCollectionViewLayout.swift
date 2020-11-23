//
//  BouncyCollectionViewLayout.swift
//  Benji
//
//  Created by Benji Dodgson on 1/6/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class BouncyCollectionViewLayout: UICollectionViewFlowLayout {

    private var damping: CGFloat = 0.9
    private var frequency: CGFloat = 2

    override init() {
        super.init()
        self.scrollDirection = .vertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)

    override func prepare() {
        super.prepare()
        guard let view = self.collectionView, let attributes = super.layoutAttributesForElements(in: view.bounds.insetBy(dx: -200, dy: -200))?.compactMap({ collectionView in collectionView.copy() as? UICollectionViewLayoutAttributes }) else { return }

        self.oldBehaviors(for: attributes).forEach { behavior in
            self.animator.removeBehavior(behavior)
        }

        self.newBehaviors(for: attributes).forEach { behavior in
            self.animator.addBehavior(behavior, self.damping, self.frequency)
        }

        self.collectionView?.contentInset.bottom = 80
        if let collectionView = self.collectionView {
            self.footerReferenceSize = CGSize(width: collectionView.width, height: 200)
        }
    }

    private func oldBehaviors(for attributes: [UICollectionViewLayoutAttributes]) -> [UIAttachmentBehavior] {
        let indexPaths = attributes.map { attribute in attribute.indexPath }

        return self.animator.behaviors.compactMap { dynamicBehavior in
            guard let behavior = dynamicBehavior as? UIAttachmentBehavior, let itemAttributes = behavior.items.first as? UICollectionViewLayoutAttributes else { return nil }
            return indexPaths.contains(itemAttributes.indexPath) ? nil : behavior
        }
    }

    private func newBehaviors(for attributes: [UICollectionViewLayoutAttributes]) -> [UIAttachmentBehavior] {
        let indexPaths = self.animator.behaviors.compactMap { behavior in
            ((behavior as? UIAttachmentBehavior)?.items.first as? UICollectionViewLayoutAttributes)?.indexPath
        }

        return attributes.compactMap { attribute in
            indexPaths.contains(attribute.indexPath) ? nil : UIAttachmentBehavior(item: attribute, attachedToAnchor: attribute.center.floored())
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.animator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.animator.layoutAttributesForCell(at: indexPath) ?? super.layoutAttributesForItem(at: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let view = self.collectionView else { return false }

        self.animator.behaviors.forEach { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior, let item = behavior.items.first else { return }

            self.update(behavior: behavior, and: item, in: view, for: newBounds)
            self.animator.updateItem(usingCurrentState: item)
        }
        return !newBounds.size.equalTo(view.bounds.size)
    }

    private func update(behavior: UIAttachmentBehavior, and item: UIDynamicItem, in view: UICollectionView, for bounds: CGRect) {
        let delta = CGVector(dx: bounds.origin.x - view.bounds.origin.x, dy: bounds.origin.y - view.bounds.origin.y)
        let resistance = CGVector(dx: abs(view.panGestureRecognizer.location(in: view).x - behavior.anchorPoint.x) / 1000, dy: abs(view.panGestureRecognizer.location(in: view).y - behavior.anchorPoint.y) / 1000)

        switch scrollDirection {
        case .horizontal: item.center.x += delta.dx < 0 ? max(delta.dx, delta.dx * resistance.dx) : min(delta.dx, delta.dx * resistance.dx)
        case .vertical: item.center.y += delta.dy < 0 ? max(delta.dy, delta.dy * resistance.dy) : min(delta.dy, delta.dy * resistance.dy)
        @unknown default:
            break 
        }

        item.center.flooredInPlace()
    }
}
