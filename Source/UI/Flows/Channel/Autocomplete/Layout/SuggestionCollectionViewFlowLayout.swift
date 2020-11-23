//
//  SuggestionCollectionViewLayout.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class SuggestionCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private(set) var isTypingIndicatorViewHidden: Bool = true

    override class var layoutAttributesClass: AnyClass {
        return SuggestionCollectionViewLayoutAttributes.self
    }

    var collectionViewWidth: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.frame.width - self.sectionInset.left - self.sectionInset.right
    }

    weak var dataSource: SuggestionCollectionViewManager? {
        didSet {
            self.invalidateLayout()
            self.collectionView?.reloadData()
        }
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
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 10
    }

    override func prepare() {
        super.prepare()

        self.collectionView?.contentInset.bottom = 10
        self.collectionView?.contentInset.top = 10
    }

    // MARK: - Attributes

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [SuggestionCollectionViewLayoutAttributes] else {
            return nil
        }

        for attributes in attributesArray where attributes.representedElementCategory == .cell {
            let suggestion = self.dataSource?.items.value[safe: attributes.indexPath.row]
            let configurer = self.configurer(for: suggestion, at: attributes.indexPath)

            if let suggestionType = suggestion {
                configurer.configure(with: suggestionType, for: self, attributes: attributes)
            }
        }

        return attributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) as? SuggestionCollectionViewLayoutAttributes else {
            return nil
        }

        if attributes.representedElementCategory == .cell, let suggestion = self.dataSource?.items.value[safe: indexPath.row] {
            let configurer = self.configurer(for: suggestion, at: indexPath)
            configurer.configure(with: suggestion, for: self, attributes: attributes)
        }

        return attributes
    }

    // MARK: - Layout Invalidation

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.collectionView?.bounds.width != newBounds.width
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard let flowLayoutContext = context as? UICollectionViewFlowLayoutInvalidationContext else { return context }
        flowLayoutContext.invalidateFlowLayoutDelegateMetrics = self.shouldInvalidateLayout(forBoundsChange: newBounds)
        return flowLayoutContext
    }

    private func configurer(for suggestion: SuggestionType?, at indexPath: IndexPath) -> SuggestionCellAttributesConfigurer {
        guard let suggestionType = suggestion else { return SuggestionCellAttributesConfigurer() }
         //Can eventually extended this to switch over different message types

        switch suggestionType {
        case .text(_):
            return TextSuggestionCellAttributesConfigurer()
        }
    }

    // MARK: - PUBLIC

    func sizeForItem(at indexPath: IndexPath, with suggestion: SuggestionType?) -> CGSize {
        return self.configurer(for: suggestion, at: indexPath).size(with: suggestion, for: self)
    }
}
