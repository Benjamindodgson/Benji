//
//  ChannelDataSource.swift
//  Benji
//
//  Created by Benji Dodgson on 7/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

typealias CompletionOptional = (() -> Void)?

protocol ChannelDataSource: AnyObject {

    var numberOfMembers: Int { get set }
    var sections: [ChannelSectionable] { get set }
    var collectionView: ChannelCollectionView { get set }

    func item(at indexPath: IndexPath) -> Messageable?
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int

    func reset()
    func set(newSections: [ChannelSectionable],
             keepOffset: Bool,
             animate: Bool,
             completion: CompletionOptional)
    func append(item: Messageable, completion: CompletionOptional)
    func updateItem(with updatedItem: Messageable,
                    replaceTypingIndicator: Bool,
                    completion: CompletionOptional)
    func delete(item: Messageable, in section: Int)
}

extension ChannelDataSource {

    func item(at indexPath: IndexPath) -> Messageable? {
        guard let section = self.sections[safe: indexPath.section],
            let item = section.items[safe: indexPath.row] else { return nil }

        return item
    }

    func numberOfSections() -> Int {
        return self.sections.count
    }

    func numberOfItems(inSection section: Int) -> Int {
        guard let section = self.sections[safe: section] else { return 0 }
        return section.items.count
    }

    func reset() {
        self.sections = []
        self.collectionView.reloadData()
    }

    func set(newSections: [ChannelSectionable],
             keepOffset: Bool = false,
             animate: Bool = false,
             completion: CompletionOptional) {

        if animate {
            self.collectionView.alpha = 0
            self.sections = newSections
            if keepOffset {
                self.collectionView.reloadDataAndKeepOffset()
            } else {
                self.collectionView.reloadData()
            }

            self.animateIn(completion: completion)
        } else {
            self.sections = newSections
            if keepOffset {
                self.collectionView.reloadDataAndKeepOffset()
                completion?()
            } else {
                self.collectionView.reloadData()
                completion?()
            }
        }
    }

    func append(item: Messageable, completion: CompletionOptional) {
        var sectionIndex: Int?
        var itemCount: Int?

        for (index, type) in self.sections.enumerated() {
            if type.date.isSameDay(as: item.createdAt) {
                sectionIndex = index
                itemCount = type.items.count
            }
        }

        if let count = itemCount, let section = sectionIndex {
            let indexPath = IndexPath(item: count, section: section)

            self.collectionView.performBatchUpdates(modifyItems: { [unowned self] in
                self.sections[section].items.append(item)
                }, updates: { [unowned self] in
                    self.collectionView.insertItems(at: [indexPath])
            }) { (completed) in
                completion?()
            }

        } else {
            //Create new section
            let new = ChannelSectionable(date: item.createdAt, items: [item])
            self.sections.append(new)
            self.collectionView.reloadData()
            completion?()
        }
    }

    func updateItem(with updatedItem: Messageable,
                    replaceTypingIndicator: Bool = false,
                    completion: CompletionOptional = nil) {

        // If there is no update id and it's from the current user,
        // then we've already displayed this message and can safely return.
        if updatedItem.updateId == nil && updatedItem.isFromCurrentUser {
            return
        }

        var indexPath: IndexPath?

        // If the new message matches an existing message's id, then replace the old one.
        if let updateId = updatedItem.updateId {
            for (sectionIndex, section) in self.sections.enumerated() {
                for (itemIndex, item) in section.items.enumerated() {
                    if item.updateId == updateId {
                        indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        break
                    }
                }
            }
        }

        // If the new message isn't replacing an old one, append it to the end.
        if indexPath == nil {
            if replaceTypingIndicator, let lastSection = self.sections.last {
                let section = self.sections.count - 1
                indexPath = IndexPath(item: lastSection.items.count - 1, section: section)
            } else {
                self.append(item: updatedItem, completion: completion)
            }
        }

        guard let ip = indexPath else { return }

        self.collectionView.performBatchUpdates(modifyItems: {
            self.sections[ip.section].items[ip.row] = updatedItem
        }, updates: {
            self.collectionView.reloadItems(at: [ip])
        }) { (completed) in
            completion?()
        }
    }
    
    func delete(item: Messageable, in section: Int = 0) {

        guard let sectionValue = self.sections[safe: section] else { return }

        var indexPath: IndexPath?

        for (index, existingItem) in sectionValue.items.enumerated() {
            if existingItem == item {
                indexPath = IndexPath(item: index, section: section)
                break
            }
        }

        guard let ip = indexPath else { return }

        self.sections[section].items.remove(at: ip.row)
        self.collectionView.deleteItems(at: [ip])
    }
}
