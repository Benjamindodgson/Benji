//
//  UITableView+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/28/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UITableView {

    // Updates the heights of the cells and headers without reloading them
    func refreshHeights() {
        self.beginUpdates()
        self.endUpdates()
    }

    func reloadSections(withIndexSets indexSets: ListIndexSetResult,
                        completion: ((Bool) -> Swift.Void)? = nil) {

        guard indexSets.hasChanges else { return }

        let sanitizedSet: ListIndexSetResult = indexSets.forBatchUpdates()

        self.performBatchUpdates({
            self.deleteSections(sanitizedSet.deletes, with: UITableView.RowAnimation.automatic)
            self.insertSections(sanitizedSet.inserts, with: UITableView.RowAnimation.automatic)
            self.reloadSections(sanitizedSet.updates, with: UITableView.RowAnimation.automatic)
            for moveIndexSet in sanitizedSet.moves {
                self.moveSection(Int(moveIndexSet.from), toSection: Int(moveIndexSet.to))
            }
        }, completion: completion)
    }

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
        guard diffResult.hasChanges else { return }

        let sanitizedResults: ListIndexPathResult = diffResult.forBatchUpdates()

        if self.frame == .zero {
            modifyItems?()
            self.reloadData()
            completion?(true)
            return
        }

        self.performBatchUpdates({

            modifyItems?()
            self.deleteRows(at: sanitizedResults.deletes, with: .automatic)
            self.insertRows(at: sanitizedResults.inserts, with: .automatic)
            self.reloadRows(at: sanitizedResults.updates, with: .automatic)
            for moveIndexPath in sanitizedResults.moves {
                self.moveRow(at: moveIndexPath.from, to: moveIndexPath.to)
            }
        }, completion: { (completed) in
            // Force table view to update otherwise the cells will reflect the old layout
            self.refreshHeights()
            completion?(completed)
        })
    }
}
