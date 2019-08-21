//
//  ChannelCollectionViewFlowLayout.swift
//  Benji
//
//  Created by Benji Dodgson on 7/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override class var layoutAttributesClass: AnyClass {
        return ChannelCollectionViewLayoutAttributes.self
    }

    lazy var messageSizeCalculator: MessageSizeCalculator = {
        let calculator = MessageSizeCalculator(layout: self)
        return calculator
    }()

    var channelCollectionView: ChannelCollectionView {
        guard let channelCollectionView = self.collectionView as? ChannelCollectionView else {
            fatalError("ChannelCollectionView NOT FOUND")
        }
        return channelCollectionView
    }

    var dataSource: ChannelDataSource {
        guard let dataSource = self.channelCollectionView.channelDataSource else {
            fatalError("ChannelDataSource is nil")
        }
        return dataSource
    }

    var itemWidth: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.frame.width - self.sectionInset.left - self.sectionInset.right
    }

    override init() {
        super.init()
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }

    private func setupView() {
        self.scrollDirection = .vertical
        self.minimumLineSpacing = 14
    }

    override func prepare() {
        super.prepare()

        self.collectionView?.contentInset.bottom = 80
        self.collectionView?.contentInset.top = 10
    }

    // MARK: - Attributes

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [ChannelCollectionViewLayoutAttributes] else {
            return nil
        }
        for attributes in attributesArray where attributes.representedElementCategory == .cell {
            let cellSizeCalculator = self.cellSizeCalculatorForItem(at: attributes.indexPath)
            cellSizeCalculator.configure(attributes: attributes)
        }
        return attributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) as? ChannelCollectionViewLayoutAttributes else {
            return nil
        }
        if attributes.representedElementCategory == .cell {
            let cellSizeCalculator = self.cellSizeCalculatorForItem(at: attributes.indexPath)
            cellSizeCalculator.configure(attributes: attributes)
        }
        return attributes
    }

    // MARK: - Layout Invalidation

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.bounds.width != newBounds.width
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard let flowLayoutContext = context as? UICollectionViewFlowLayoutInvalidationContext else { return context }
        flowLayoutContext.invalidateFlowLayoutDelegateMetrics = self.shouldInvalidateLayout(forBoundsChange: newBounds)
        return flowLayoutContext
    }

    private func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        //Can eventually extended this to switch over different message types and size calculators
        return self.messageSizeCalculator
    }

    // MARK: - PUBLIC

    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let calculator = self.cellSizeCalculatorForItem(at: indexPath)
        return calculator.sizeForItem(at: indexPath)
    }
}
