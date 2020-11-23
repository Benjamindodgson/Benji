//
//  UICollectionView+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UICollectionView {

    func reload<T: Diffable>(previousItems: [T],
                             newItems: [T],
                             equalityOption: IGListDiffOption,
                             modify: @escaping () -> Swift.Void,
                             completion: ((Bool) -> Swift.Void)? = nil) {

        let previousBoxItems: [ListDiffable] = previousItems.map { (item) -> ListDiffable in
            return DiffableBox<T>(value: item, equal: ==)
        }

        let newBoxItems: [ListDiffable] = newItems.map { (item) -> ListDiffable in
            return DiffableBox<T>(value: item, equal: ==)
        }

        self.reload(previousItems: previousBoxItems,
                    newItems: newBoxItems,
                    equalityOption: equalityOption,
                    modifyItems: modify,
                    completion: completion)
    }

    func reload(previousItems: [ListDiffable],
                newItems: [ListDiffable],
                equalityOption: IGListDiffOption,
                modifyItems: (() -> Swift.Void)? = nil,
                completion: ((Bool) -> Swift.Void)? = nil) {


        let diffResult: ListIndexPathResult = ListDiffPaths(fromSection: 0,
                                                            toSection: 0,
                                                            oldArray: previousItems,
                                                            newArray: newItems,
                                                            option: equalityOption)
        self.reloadItems(withDiffResult: diffResult,
                         modifyItems: modifyItems,
                         completion: completion)
    }

    private func reloadItems(withDiffResult diffResult: ListIndexPathResult,
                             modifyItems: (() -> Swift.Void)? = nil,
                             completion: ((Bool) -> Swift.Void)? = nil) {

        // Don't reload the collection view if no changes have been made to the items array
        guard diffResult.hasChanges else {
            completion?(true)
            return
        }

        let sanitizedResults: ListIndexPathResult = diffResult.forBatchUpdates()
        runMain {
            if self.frame == .zero {
                modifyItems?()
                self.reloadData()
                completion?(true)
                return
            }

            self.performBatchUpdates({

                modifyItems?()

                self.deleteItems(at: sanitizedResults.deletes)
                self.insertItems(at: sanitizedResults.inserts)
                self.reloadItems(at: sanitizedResults.updates)
                for moveIndexPath in sanitizedResults.moves {
                    self.moveItem(at: moveIndexPath.from, to: moveIndexPath.to)
                }
            }, completion: { (completed) in
                // Force collection view to update otherwise the cells will reflect the old layout
                self.collectionViewLayout.invalidateLayout()
                completion?(completed)
            })
        }
    }

    func reloadWithModify<T: Diffable>(previousItems: [T],
                                       newItems: [T],
                                       equalityOption: IGListDiffOption,
                                       modify: @escaping () -> Swift.Void,
                                       completion: ((Bool) -> Swift.Void)? = nil) {

        let previousBoxItems: [ListDiffable] = previousItems.map { (item) -> ListDiffable in
            return DiffableBox<T>(value: item, equal: ==)
        }

        let newBoxItems: [ListDiffable] = newItems.map { (item) -> ListDiffable in
            return DiffableBox<T>(value: item, equal: ==)
        }

        self.reload(previousItems: previousBoxItems,
                    newItems: newBoxItems,
                    equalityOption: equalityOption,
                    modifyItems: modify,
                    completion: completion)
    }

    func performBatchUpdates(modifyItems: (() -> Swift.Void)? = nil,
                             updates: (() -> Swift.Void)? = nil,
                             completion: ((Bool) -> Swift.Void)? = nil) {

        if self.frame == .zero {
            modifyItems?()
            self.reloadData()
            completion?(true)
            return
        }

        self.performBatchUpdates({
            modifyItems?()
            updates?()
        }, completion: { (completed) in
            // Force collection view to update otherwise the cells will reflect the old layout
            self.collectionViewLayout.invalidateLayout()
            completion?(completed)
        })
    }

    func centerMostIndexPath() -> IndexPath? {
        let point = CGPoint(x: self.halfWidth + self.contentOffset.x,
                            y: self.halfHeight + self.contentOffset.y)
        guard let indexPath = self.indexPathForItem(at: point) else { return nil }

        return indexPath
    }
}
