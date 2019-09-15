//
//  CollectionView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CollectionView: UICollectionView {

    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    init(flowLayout: UICollectionViewFlowLayout) {
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        self.set(backgroundColor: .clear)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func scrollToBottom(animated: Bool = true) {
        let collectionViewContentHeight = collectionViewLayout.collectionViewContentSize.height

        self.performBatchUpdates(nil) { _ in
            self.scrollRectToVisible(CGRect(x: 0.0,
                                            y: collectionViewContentHeight - 1.0,
                                            width: 1.0, height: 1.0),
                                     animated: animated)
        }
    }

    func initialize() {
        self.addSubview(self.activityIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.activityIndicator.centerOnXAndY()
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
