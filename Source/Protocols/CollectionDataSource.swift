//
//  ChannelDataSource.swift
//  Benji
//
//  Created by Benji Dodgson on 7/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol ChannelDataSource: AnyObject {

    var sections: MutableProperty<[ChannelSectionType]> { get set }
    var previousSections: [ChannelSectionType]? { get set }
    var collectionView: CollectionView? { get set }

    func item(at indexPath: IndexPath) -> MessageType?
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int

    func reset()
    func set(newSections: [ChannelSectionType])
    func append(item: MessageType)
    func update(item: MessageType, in section: Int)
    func delete(item: MessageType, in section: Int)
}

extension ChannelDataSource {

    func item(at indexPath: IndexPath) -> MessageType? {
        guard let section = self.sections.value[safe: indexPath.section],
            let item = section.items[safe: indexPath.row] else { return nil }

        return item
    }

    func numberOfSections() -> Int {
        return self.sections.value.count
    }

    func numberOfItems(inSection section: Int) -> Int {
        guard let section = self.sections.value[safe: section] else { return 0 }
        return section.items.count
    }

    func reset() {
        self.sections.value = []
        self.previousSections = nil
        self.collectionView?.reloadData()
    }

    func set(newSections: [ChannelSectionType]) {
        self.sections.value = newSections
        self.collectionView?.reloadData()

        //FIX ME!!!!
//        self.updateCollectionView(sections: newSections, modify: { [weak self] in
//            guard let `self` = self else { return }
//            self.sections.value = newSections
//        })
    }

    func append(item: MessageType) {
        var sectionIndex: Int?
        var itemCount: Int?
        
        for (index, type) in self.sections.value.enumerated() {
            if type.date.isSameDay(as: item.createdAt) {
                sectionIndex = index
                itemCount = type.items.count
            }
        }

        if let count = itemCount, let section = sectionIndex {
            let indexPath = IndexPath(item: count, section: section)

            self.sections.value[section].items.append(item)
            self.collectionView?.insertItems(at: [indexPath])
        } else {
            //Create new section
            let newSection = ChannelSectionType(date: item.createdAt, items: [item])
            self.sections.value.append(newSection)
            self.collectionView?.reloadData()
        }
    }

    func update(item: MessageType, in section: Int = 0) {
        guard let sectionValue = self.sections.value[safe: section] else { return }

        var indexPath: IndexPath?

        for (index, existingItem) in sectionValue.items.enumerated() {
            if existingItem == item {
                indexPath = IndexPath(item: index, section: section)
                break
            }
        }

        guard let ip = indexPath else { return }

        self.sections.value[section].items[ip.row] = item
        self.collectionView?.reloadItems(at: [ip])
    }

    func delete(item: MessageType, in section: Int = 0) {

        guard let sectionValue = self.sections.value[safe: section] else { return }

        var indexPath: IndexPath?

        for (index, existingItem) in sectionValue.items.enumerated() {
            if existingItem == item {
                indexPath = IndexPath(item: index, section: section)
                break
            }
        }

        guard let ip = indexPath else { return }

        self.sections.value[section].items.remove(at: ip.row)
        self.collectionView?.deleteItems(at: [ip])
    }

    private func updateCollectionView(sections: [ChannelSectionType], modify: @escaping () -> Void) {

        let previous = self.previousSections ?? []
        self.reloadCollectionView(previousSections: previous,
                                  newSections: sections,
                                  modify: modify)

        self.previousSections = sections
    }

    private func reloadCollectionView(previousSections: [ChannelSectionType],
                                      newSections: [ChannelSectionType],
                                      modify: @escaping () -> Void) {

        self.collectionView?.reload(previousItems: previousSections,
                                    newItems: newSections,
                                    equalityOption: .equality,
                                    modify: modify,
                                    completion: nil)
    }
}
