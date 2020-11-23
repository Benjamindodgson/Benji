//
//  ChannelCollectionViewFlowLayout.swift
//  Benji
//
//  Created by Benji Dodgson on 7/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private(set) var isTypingIndicatorViewHidden: Bool = true
    private var insertingIndexPaths: [IndexPath] = []
    let readFooterHeight: CGFloat = 40

    override class var layoutAttributesClass: AnyClass {
        return ChannelCollectionViewLayoutAttributes.self
    }

    weak var dataSource: ChannelDataSource? {
        didSet {
            self.invalidateLayout()
            self.collectionView?.reloadData()
        }
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
        self.minimumLineSpacing = 4
    }

    override func prepare() {
        super.prepare()

        self.collectionView?.contentInsetAdjustmentBehavior = .automatic
        self.collectionView?.contentInset.top = 84
        self.footerReferenceSize = CGSize(width: self.itemWidth, height: self.readFooterHeight)
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        self.insertingIndexPaths.removeAll()

        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate,
                update.updateAction == .insert {
                self.insertingIndexPaths.append(indexPath)
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        self.insertingIndexPaths.removeAll()
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

        if self.insertingIndexPaths.contains(itemIndexPath) {
            attributes?.alpha = 0.0
            attributes?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }

        return attributes
    }

    // MARK: - Attributes

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [ChannelCollectionViewLayoutAttributes] else {
            return nil
        }

        for attributes in attributesArray where attributes.representedElementCategory == .cell {
            let message = self.dataSource?.item(at: attributes.indexPath)
            let configurer = self.configurer(for: message, at: attributes.indexPath)
            let adjacentMessages = self.getAdjacentMessages(for: attributes.indexPath)
            if let msg = message {
                configurer.configure(with: msg,
                                     previousMessage: adjacentMessages.previousMessage,
                                     nextMessage: adjacentMessages.nextMessage,
                                     for: self,
                                     attributes: attributes)
            }
        }

        for attributes in attributesArray where attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
            if let configurer = self.headerConfigurer(for: attributes.indexPath.section) {
                configurer.configure(attributes: attributes, for: self)
            }
        }

        return attributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) as? ChannelCollectionViewLayoutAttributes else {
            return nil
        }

        if attributes.representedElementCategory == .cell, let message = self.dataSource?.item(at: indexPath) {
            let configurer = self.configurer(for: message, at: indexPath)
            let adjacentMessages = self.getAdjacentMessages(for: attributes.indexPath)

            configurer.configure(with: message,
                                 previousMessage: adjacentMessages.previousMessage,
                                 nextMessage: adjacentMessages.nextMessage,
                                 for: self,
                                 attributes: attributes)
        } else if attributes.representedElementKind == UICollectionView.elementKindSectionHeader,
            let configurer = self.headerConfigurer(for: attributes.indexPath.section) {

            configurer.configure(attributes: attributes, for: self)
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

    private func configurer(for message: Messageable?, at indexPath: IndexPath) -> ChannelCellAttributesConfigurer {
        // Can eventually extended this to switch over different message types

        if self.isSectionReservedForTypingIndicator(indexPath.section) {
            return TypingCellAttributesConfigurer()
        }

        if let kind = message?.kind {
            switch kind {
            case .text(let text):
                if text.isEmpty {
                    return ChannelCellAttributesConfigurer()
                }
                return MessageCellAttributesConfigurer()
            case .attributedText(_):
                return AttributedMessageCellAttributesConfigurer()
            case .photo(_):
                return PhotoCellAttributesConfigurer()
            case .video(_):
                return VideoAttributesCellConfigurer()
            case .location(_):
                return LocationCellAttributesConfigurer()
            case .emoji(_):
                return EmojiCellAttributesConfigurer()
            case .audio(_):
                return AudioCellAttributesConfigurer()
            case .contact(_):
                return ContactCellAttributesConfigurer()
            }
        }

        return ChannelCellAttributesConfigurer()
    }

    private func getAdjacentMessages(for indexPath: IndexPath) -> AdjacectMessages {

        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        let previousMessage = self.dataSource?.item(at: previousIndexPath)

        let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
        let nextMessage = self.dataSource?.item(at: nextIndexPath)

        return AdjacectMessages(previousMessage: previousMessage, nextMessage: nextMessage)
    }

    private func headerConfigurer(for section: Int) -> ChannelHeaderAttributesConfigurer? {
        if section == 0,
            let messageIndex = self.dataSource?.item(at: IndexPath(item: 0, section: 0))?.messageIndex,
            messageIndex == 0 {
            return ChannelIntroHeaderAttributesConfigurer()
        }
        
        return nil
    }

    // MARK: - PUBLIC

    func sizeForItem(at indexPath: IndexPath, with message: Messageable?) -> CGSize {
        return self.configurer(for: message, at: indexPath).size(with: message, for: self)
    }

    func sizeForHeader(at section: Int, with collectionView: UICollectionView) -> CGSize {

        if self.isSectionReservedForTypingIndicator(section) {
            return .zero
        }

        if let configurer = self.headerConfigurer(for: section) {
            return configurer.sizeForHeader(at: section, for: self)
        }

        return CGSize(width: collectionView.width, height: 60)
    }

    // MARK: - Typing Indicator API

    /// Notifies the layout that the typing indicator will change state
    ///
    /// - Parameters:
    ///   - isHidden: A Boolean value that is to be the new state of the typing indicator
    func setTypingIndicatorViewHidden(_ isHidden: Bool) {
        self.isTypingIndicatorViewHidden = isHidden
    }

    /// A method that by default checks if the section is the last in the
    /// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
    /// is FALSE
    ///
    /// - Parameter section
    /// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
    func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
        guard let collectionView = self.collectionView else { return false }
        return !self.isTypingIndicatorViewHidden && section == collectionView.numberOfSections - 1
    }
}

private struct AdjacectMessages {
    var previousMessage: Messageable?
    var nextMessage: Messageable?
}
