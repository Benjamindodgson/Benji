//
//  CollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CollectionView: UICollectionView {


    init(layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
        self.set(backgroundColor: .clear)
        self.initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeViews() {
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    func scrollToEnd(animated: Bool = true, completion: CompletionOptional = nil) {

        var rect: CGRect = .zero
        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout,
            flowLayout.scrollDirection == .vertical {

            let contentHeight = self.collectionViewLayout.collectionViewContentSize.height
            rect = CGRect(x: 0.0,
                          y: contentHeight - 1.0,
                          width: 1.0,
                          height: 1.0)
        } else {
            let contentWidth = self.collectionViewLayout.collectionViewContentSize.width
            rect = CGRect(x: contentWidth - 1.0,
                          y: 0,
                          width: 1.0,
                          height: 1.0)
        }

        self.performBatchUpdates({
            self.scrollRectToVisible(rect, animated: animated)
        }) { (completed) in
            completion?()
        }
    }

    func reloadDataAndKeepOffset() {
        // stop scrolling
        self.setContentOffset(self.contentOffset, animated: false)

        // calculate the offset and reloadData
        let beforeContentSize = self.contentSize
        self.reloadData()
        self.layoutIfNeeded()
        let afterContentSize = self.contentSize

        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: self.contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: self.contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        self.setContentOffset(newOffset, animated: false)
    }

    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: T.self))
    }

    /// Registers a reusable view for a specific SectionKind
    func register<T: UICollectionReusableView>(_ reusableViewClass: T.Type,
                                               forSupplementaryViewOfKind kind: String) {
        self.register(reusableViewClass,
                      forSupplementaryViewOfKind: kind,
                      withReuseIdentifier: String(describing: T.self))
    }

    /// Generically dequeues a cell of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Unable to dequeue \(String(describing: cellClass)) with reuseId of \(String(describing: T.self))")
        }
        return cell
    }

    /// Generically dequeues a header of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
    func dequeueReusableHeaderView<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: T.self), for: indexPath)
        guard let viewType = view as? T else {
            fatalError("Unable to dequeue \(String(describing: viewClass)) with reuseId of \(String(describing: T.self))")
        }
        return viewType
    }

    /// Generically dequeues a footer of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
    func dequeueReusableFooterView<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: T.self), for: indexPath)
        guard let viewType = view as? T else {
            fatalError("Unable to dequeue \(String(describing: viewClass)) with reuseId of \(String(describing: T.self))")
        }
        return viewType
    }
}
